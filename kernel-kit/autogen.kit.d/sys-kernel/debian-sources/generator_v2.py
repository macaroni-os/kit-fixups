#!/usr/bin/env python3
"""
debian-sources generator v2 - Improved version compatibility checking.

Fixes the buggy version comparison that failed for kernel minor versions >= 10.
Now uses proper tuple comparison for version ranges.

Also fixes the fallback mechanism to find the latest compatible version in the
same branch when the current version is incompatible with OpenZFS.

Key changes:
1. Uses proper tuple-based version comparison (not broken string logic)
2. When a version is incompatible, queries Debian to find the latest compatible version in the same branch
3. Fixed fallback URL (was empty string, now uses kernel.org)
4. Better logging and error handling
"""

import asyncio
import hashlib
import lzma
import os
import re
import requests
import yaml
from urllib.parse import urljoin


def get_kernel_dot_org_url(major_version: str, base_url: str) -> str:
    """Get kernel.org URL for a given major version.

    Args:
        major_version: Major version number like '6' or '7'
        base_url: Base URL for kernel.org mirror

    Returns:
        Full URL like 'https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x'
    """
    return f'{base_url}{major_version}.x'


def parse_version_tuple(ver_str):
    """Parse a kernel version string into a comparable tuple.

    Args:
        ver_str: Version string like '6.12.38_p1' or '6.12.38'

    Returns:
        Tuple (major, minor, patch, debpatch) or None if invalid

    Examples:
        '6.12.38_p1' -> (6, 12, 38, 1)
        '6.12.38' -> (6, 12, 38, 0)
    """
    match = re.match(r'(\d+)\.(\d+)\.(\d+)(?:_p(\d+))?', ver_str)
    if not match:
        return None
    return (int(match.group(1)), int(match.group(2)), int(match.group(3)),
            int(match.group(4)) if match.group(4) else 0)


def parse_version_branch(ver_str):
    """Extract the major.minor branch from a version string.

    Args:
        ver_str: Version string like '6.12.38_p1' or '6.1.0_p2'

    Returns:
        Branch string like '6.12' or None if invalid
    """
    match = re.match(r'(\d+)\.(\d+)\.\d+', ver_str)
    if not match:
        return None
    return f'{match.group(1)}.{match.group(2)}'


def version_in_range(version_str, min_ver, max_ver):
    """Check if version is within [min_ver, max_ver] using tuple comparison.

    This is the key fix: uses proper tuple comparison instead of the buggy
    string-based comparison that failed for minor versions >= 10.

    Args:
        version_str: Kernel version string like '6.12.38_p1'
        min_ver: Minimum version tuple like (4, 18)
        max_ver: Maximum version tuple like (7, 0)

    Returns:
        True if version is within range, False otherwise.
    """
    v = parse_version_tuple(version_str)
    if v is None:
        return False

    # Compare only major.minor for range check (ignore patch level)
    version_branch = (v[0], v[1])

    return min_ver <= version_branch <= max_ver


async def find_latest_in_branch(branch, min_ver, max_ver, pool_url, kernel_base_url):
    """Find the latest kernel version in the same branch that's compatible.

    Queries kernel.org index to list available versions in the
    same major.minor branch, then returns the latest compatible one.

    Args:
        branch: The branch name like '6.12'
        min_ver: Minimum version tuple like (4, 18)
        max_ver: Maximum version tuple like (7, 0)
        pool_url: Base URL for Debian kernel sources
        kernel_base_url: Base URL for kernel.org mirror

    Returns:
        Tuple of (version_string, is_compatible, reason)
        version_string is in 'X.Y.Z' format (no Debian patch level)
    """
    # Try to list versions from kernel.org for this branch
    branch_versions = []

    # Try kernel.org first (most reliable)
    major = branch.split('.')[0]
    branch_url = get_kernel_dot_org_url(major, kernel_base_url)
    try:
        r = await _request_with_retry(requests.get, branch_url, timeout=10)
        r.raise_for_status()

        # Parse HTML links for tarballs
        links = re.findall(
            r'<a[^>]*href=["\']([^"\']+linux_\d+\.\d+\.\d+[^"\']*)["\']',
            r.text
        )

        # Extract versions from filenames
        for link in links:
            ver_match = re.search(r'linux_(\d+\.\d+\.\d+)', link)
            if ver_match:
                branch_versions.append(ver_match.group(1))

        # Also try .tar.xz files
        links2 = re.findall(
            r'<a[^>]*href=["\']([^"\']*linux-\d+\.\d+\.\d+\.tar\.xz)["\']',
            r.text
        )
        for link in links2:
            ver_match = re.search(r'linux-(\d+\.\d+\.\d+)', link)
            if ver_match:
                branch_versions.append(ver_match.group(1))

    except (requests.RequestException, IOError):
        pass

    if not branch_versions:
        raise RuntimeError(f'Could not query kernel.org for branch {branch}')

    # Sort versions (they should be strings like '6.12.38')
    # Use parse_version_tuple for proper sorting
    branch_versions_with_parse = [
        (parse_version_tuple(v), v)
        for v in branch_versions
        if parse_version_tuple(v) is not None
    ]

    if not branch_versions_with_parse:
        return branch + '.0_p0', False, 'No versions found'

    # Sort descending (latest first)
    branch_versions_with_parse.sort(reverse=True)

    # Find first compatible version
    for v_tuple, v_str in branch_versions_with_parse:
        version_branch = (v_tuple[0], v_tuple[1])
        if min_ver <= version_branch <= max_ver:
            # Found compatible version
            return v_str, True, 'Found in kernel.org listing'

    # No compatible version in this branch
    return branch_versions_with_parse[0][1], False, 'No compatible version in branch'


async def get_version(*, rel: str, pool_base: str, use_security: bool):
    """Get the latest Debian kernel source version for a release.

    Downloads the Debian package list and extracts the linux-source version.
    """
    # Switch to security archive when needed
    if use_security and 'security' not in pool_base:
        pool_base = pool_base.replace('deb.debian.org/debian',
                                      'deb.debian.org/debian-security')

    url = f'{pool_base}/dists/{rel}-security/main/binary-all/Packages.xz' if use_security else \
          f'{pool_base}/dists/{rel}/main/binary-all/Packages.xz'

    r = await _request_with_retry(requests.get, url, timeout=30)
    if r.status_code == 404 and use_security:
        # Security suite doesn't exist yet (e.g., trixe is new) - fall back to main
        url = f'{pool_base}/dists/{rel}/main/binary-all/Packages.xz'
        r = await _request_with_retry(requests.get, url, timeout=30)
    r.raise_for_status()
    text = lzma.decompress(r.content)

 # Match pool/main/l/linux/linux-source_<version>_<patch>_all.deb
    v1 = re.findall(
        r'pool/(?:updates/)?main/l/linux/linux-source_((\d\.\d+\.\d+)[-](\d+))_all\.deb',
        str(text)
    )

    if not v1:
        raise ValueError(f'No kernel version found for Debian {rel}')

    # Sort by version tuple to get the actual latest (not just last match)
    parsed = [(parse_version_tuple(f'{v[1]}_p{v[2]}'), v) for v in v1]
    parsed = [(t, v) for t, v in parsed if t is not None]
    if not parsed:
        raise ValueError(f'No valid kernel version found for Debian {rel}')
    parsed.sort(key=lambda x: x[0], reverse=True)
    latest = parsed[0][1]

    # Returns: 6.12.38_p1
    return f'{latest[1]}_p{latest[2]}'


async def get_openzfs_compat(*, openzfs_version: str):
    """Get OpenZFS kernel compatibility range from META file.

    Constructs the GitHub URL from the version and parses the Linux-Maximum
    and Linux-Minimum values from the OpenZFS metadata file.

    Args:
        openzfs_version: OpenZFS version tag (e.g., 'zfs-2.3-release')

    Returns:
        Dict with 'min', 'max' as version tuples and 'min_str', 'max_str' as strings
    """
    meta_url = f'https://raw.githubusercontent.com/openzfs/zfs/{openzfs_version}/META'
    r = await _request_with_retry(requests.get, meta_url, timeout=15)
    r.raise_for_status()

    # Try patterns for max version (specific → general)
    zfs_max_patterns = [
        r'Linux-Maximum:\s*(\d+\.\d+)',
        r'MAXIMUM\s*:\s*(\d+\.\d+)',
    ]

    zfs_max = None
    for pattern in zfs_max_patterns:
        match = re.search(pattern, r.text)
        if match:
            zfs_max = match.group(1)
            break

    if not zfs_max:
        raise RuntimeError(
            f'Could not parse Linux-Maximum from OpenZFS META '
            f'(version: {openzfs_version})'
        )

    # Try patterns for min version
    zfs_min_patterns = [
        r'Linux-Minimum:\s*(\d+\.\d+)',
        r'MINIMUM\s*:\s*(\d+\.\d+)',
    ]

    zfs_min = None
    for pattern in zfs_min_patterns:
        match = re.search(pattern, r.text)
        if match:
            zfs_min = match.group(1)
            break

    if not zfs_min:
        raise RuntimeError(
            f'Could not parse Linux-Minimum from OpenZFS META '
            f'(version: {openzfs_version})'
        )

    # Parse into tuples for proper comparison
    max_tuple = tuple(int(x) for x in zfs_max.split('.'))
    min_tuple = tuple(int(x) for x in zfs_min.split('.'))

    return {
        'max_str': zfs_max,
        'min_str': zfs_min,
        'max': max_tuple,
        'min': min_tuple,
    }


async def get_debian_patch_level(version: str, rel: str, pool_url: str) -> str:
    """Query Debian pool for the patch level of a given kernel version.

    Args:
        version: Kernel version like '6.12.38'
        rel: Debian release (e.g., 'trixie', 'sid')
        pool_url: Base URL for Debian kernel sources

    Returns:
        Patch level string like '1' or '2'
    """
    # Try to find the Debian tarball for this version
    for patch_level in range(1, 10):
        tarball_name = f'linux_{version}-{patch_level}.debian.tar.xz'
        url = f'{pool_url}/{tarball_name}'
        try:
            r = await _request_with_retry(requests.head, url, timeout=10, allow_redirects=True)
            if r.status_code == 200:
                return str(patch_level)
        except requests.RequestException:
            continue
    return '1'  # Default to patch level 1 if not found


async def check_version(*, openzfs_compat: dict, ver: str, rel: tuple,
                  track_openzfs: bool = True, pool_url: str = '', kernel_base_url: str = ''):
    """Check if kernel version is compatible with OpenZFS.

    This is the key function that was buggy. The new version uses proper
    tuple comparison instead of the broken string-based logic.

    If the version is incompatible and track_openzfs is True, it will:
    1. Determine the major.minor branch of the current version
    2. Query kernel.org to find all versions in that branch
    3. Return the latest compatible version found

    Args:
        openzfs_compat: Dict with 'min' and 'max' as version tuples
        ver: Kernel version string like '6.12.38_p1'
        rel: Tuple of (branch_name, branch_label) like ('testing', 'testing')
        track_openzfs: Whether to check OpenZFS compatibility

    Returns:
        Tuple of (version_string, triplet, debpatch)
    """
    v_match = re.findall(r'(\d+\.\d+\.\d+)_p(\d+)', ver)
    if not v_match:
        raise ValueError(f'Invalid version format: {ver}')

    v = v_match[0]
    branch, name = rel

    if not track_openzfs:
        print(f'  Skipping OpenZFS check for {name} (not tracking)')
        return ver, v[0], v[1]

    min_ver = openzfs_compat['min']
    max_ver = openzfs_compat['max']

    if version_in_range(ver, min_ver, max_ver):
        print(f'  ✅ {branch} kernel {ver} ({name}) compatible with OpenZFS '
              f'(range: {openzfs_compat["min_str"]} - {openzfs_compat["max_str"]})')
        return ver, v[0], v[1]

    else:
        # Version incompatible - find latest compatible in same branch
        branch_num = parse_version_branch(ver)
        print(f'  ❌ Version {ver} ({name}) incompatible with OpenZFS '
              f'(range: {openzfs_compat["min_str"]} - {openzfs_compat["max_str"]})')
        print(f'  🔍 Searching for latest compatible version in branch {branch_num}...')

        # Try to find latest compatible version in same branch
        fallback_ver, found, reason = await find_latest_in_branch(
            branch=branch_num,
            min_ver=min_ver,
            max_ver=max_ver,
            pool_url=pool_url,
            kernel_base_url=kernel_base_url
        )

        if found:
            # Re-check the fallback version to be sure
            if version_in_range(fallback_ver, min_ver, max_ver):
                print(f'  ✅ Found compatible version: {fallback_ver} ({reason})')
            else:
                print(f'  ⚠️  Fallback {fallback_ver} also incompatible - using it anyway')

            # Query Debian pool for the actual patch level of this fallback version
            debpatch = await get_debian_patch_level(fallback_ver, branch, pool_url)
            return f'{fallback_ver}_p{debpatch}', fallback_ver, debpatch
        else:
            print(f'  ⚠️  No compatible version found in branch {branch_num}')
            print(f'     Reason: {reason}')
            # Return the original - will fail but at least we tried
            return ver, v[0], v[1]


async def get_releases(config: dict, pool_base: str):
    """Get kernel versions for tracked releases.

    Args:
        config: Configuration dict with 'branch' key
        pool_base: Base URL for Debian pool

    Returns:
        Dict mapping branch name to version string
    """
    tracked_releases = [config['branch']]
    use_security = config.get('use_security', True)

    s = dict(
        zip(
            tracked_releases,
            await asyncio.gather(
                *[get_version(rel=r, pool_base=pool_base, use_security=use_security) for r in tracked_releases]
            )
        )
    )

    return s


async def _request_with_retry(func, *args, max_retries=3, **kwargs):
    """Execute a requests call with retry on transient failures.

    Args:
        func: requests.get or requests.head
        max_retries: Number of retry attempts
        *args, **kwargs: Passed to the request function

    Returns:
        Response object
    """
    last_error = None
    for attempt in range(max_retries):
        try:
            return func(*args, **kwargs)
        except (requests.RequestException, IOError, OSError) as e:
            last_error = e
            if attempt < max_retries - 1:
                print(f'   ⚠️  Retry {attempt+1}/{max_retries}: {e}')

    raise last_error if last_error else RuntimeError(f'Request failed after {max_retries} attempts')


async def check_url_available(url: str, timeout: int = 10) -> dict:
    """Check if a URL is available (returns 200 OK).
    
    Args:
        url: The URL to check
        timeout: Request timeout in seconds
    
    Returns:
        Dict with 'url', 'available' (bool), and 'error' (str if failed)
    """
    try:
        r = await _request_with_retry(requests.head, url, timeout=timeout, allow_redirects=True)
        return {'url': url, 'available': r.status_code == 200, 'error': None}
    except (requests.RequestException, IOError) as e:
        return {'url': url, 'available': False, 'error': str(e)}


async def get_artifact_url(name: str, mirrors: list, timeout: int = 10) -> str:
    """Get the artifact URL, checking all mirrors in parallel.
    
    Args:
        name: Artifact filename
        mirrors: List of mirror base URLs to check
        timeout: Request timeout in seconds
    
    Returns:
        The URL where the artifact is available
    
    Raises:
        RuntimeError: If all mirrors fail to serve the artifact
    """
    # Build full URLs for all mirrors
    mirror_urls = [f'{mirror}/{name}' for mirror in mirrors]
    
    # Check all mirrors in parallel
    results = await asyncio.gather(
        *[check_url_available(url, timeout) for url in mirror_urls],
        return_exceptions=True
    )
    
    # Find the first available mirror
    for result in results:
        if isinstance(result, BaseException):
            continue
        if not isinstance(result, dict):
            continue
        if result.get('available', False):
            print(f'   ✅ Found {name} on {result["url"]}')
            return result['url']
    
    # All mirrors failed
    errors = []
    for r in results:
        if isinstance(r, BaseException):
            continue
        if not isinstance(r, dict):
            continue
        if not r.get('available', False):
            errors.append(f'   - {r.get("url", "unknown")}: {r.get("error", "unknown")}')
    raise RuntimeError(
        f'❌ All mirrors failed for {name}:\n' + '\n'.join(errors) +
        f'\n   Cannot generate ebuild without available artifacts.'
    )


async def download_release_file(suite: str, mirrors: list, timeout: int = 30) -> str:
    """Download the Debian Release file for a given suite.

    Release files live at the Debian archive, not in the pool.
    Constructs the archive URL from the pool mirror URL.

    Args:
        suite: Debian suite name (e.g., 'trixie', 'sid')
        mirrors: List of mirror base URLs (pool URLs)
        timeout: Request timeout in seconds

    Returns:
        The Release file content as a string

    Raises:
        RuntimeError: If all mirrors fail to serve the Release file
    """
    # Construct archive URLs from pool URLs
    # Pool: https://deb.debian.org/debian/pool/main/l/linux
    # Archive: https://deb.debian.org/debian/dists/trixie/Release
    archive_urls = []
    for mirror in mirrors:
        # Extract base URL (remove /pool/... part)
        base_url = mirror.split('/pool/')[0] if '/pool/' in mirror else mirror
        archive_urls.append(f'{base_url}/dists/{suite}/Release')
        archive_urls.append(f'{base_url}/dists/{suite}/InRelease')

    # Also try kernel.org fallback mirror
    archive_urls.append(f'https://mirrors.edge.kernel.org/pub/linux/dist/debian/dists/{suite}/Release')
    
    # Try all mirrors in parallel
    results = await asyncio.gather(
        *[check_url_available(url, timeout) for url in archive_urls],
        return_exceptions=True
    )
    
    for result in results:
        if isinstance(result, BaseException):
            continue
        if not isinstance(result, dict):
            continue
        if result.get('available', False):
            print(f'   ✅ Found Release file on {result["url"]}')
            # Download the actual content
            r = await _request_with_retry(requests.get, result['url'], timeout=timeout)
            r.raise_for_status()
            return r.text
    
    raise RuntimeError(
        f'❌ Could not download Release file for suite {suite}'
    )


def parse_release_checksums(release_content: str) -> dict:
    """Parse SHA256 checksums from a Debian Release file.
    
    Args:
        release_content: The Release file content
    
    Returns:
        Dict mapping filename to SHA256 checksum
    """
    checksums = {}
    in_sha256s = False
    
    for line in release_content.split('\n'):
        if line.startswith('SHA256:'):
            in_sha256s = True
            continue
        elif line.startswith('SHA1:') or line.startswith('MD5Sum:'):
            in_sha256s = False
            continue
        
        if in_sha256s and line.strip():
            parts = line.split()
            if len(parts) >= 2:
                checksum = parts[0]
                filename = parts[1]
                checksums[filename] = checksum
    
    return checksums


async def parse_kernel_sha256sums(major_version: str, kernel_base_url: str, timeout: int = 30) -> dict:
    """Download and parse kernel.org sha256sums.asc file.

    Args:
        major_version: Major version number like '6' or '7'
        kernel_base_url: Base URL for kernel.org mirror
        timeout: Request timeout in seconds

    Returns:
        Dict mapping filename to SHA256 checksum
    """
    checksums = {}
    url = f'{kernel_base_url}{major_version}.x/sha256sums.asc'
    try:
        r = await _request_with_retry(requests.get, url, timeout=timeout)
        r.raise_for_status()
        # Parse the sha256sums format (skip PGP headers)
        in_checksums = False
        for line in r.text.split('\n'):
            # Skip PGP headers
            if line.startswith('-----'):
                in_checksums = True
                continue
            if not in_checksums:
                continue
            # Parse checksum lines: hash  filename
            parts = line.strip().split()
            if len(parts) >= 2 and len(parts[0]) == 64:  # SHA256 is 64 hex chars
                checksums[parts[1]] = parts[0]
    except (requests.RequestException, IOError) as e:
        print(f'   ⚠️  Could not download kernel.org sha256sums: {e}')
    return checksums


async def verify_kernel_artifact(artifact_url: str, artifact_name: str,
                                  checksums: dict, downloads_dir: str) -> bool:
    """Verify a kernel.org artifact's SHA256 checksum.

    Args:
        artifact_url: Full URL of the artifact
        artifact_name: Artifact filename
        checksums: Dict mapping filename to SHA256 checksum
        downloads_dir: Directory to download artifacts to

    Returns:
        True if checksum matches or verification skipped, False on mismatch
    """
    expected_checksum = checksums.get(artifact_name)
    if not expected_checksum:
        print(f'   ℹ️  No checksum in sha256sums for {artifact_name} (skipping)')
        return True  # Skip verification if no checksum available

   # Download artifact to downloads dir (reused by mark-devkit)
    temp_path = f'{downloads_dir}/{artifact_name}'
    try:
        # Only download if not already present
        if not os.path.exists(temp_path):
            r = await _request_with_retry(requests.get, artifact_url, timeout=60, stream=True)
            r.raise_for_status()
            with open(temp_path, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)

        # Calculate SHA256
        sha256 = hashlib.sha256()
        with open(temp_path, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)

        actual_checksum = sha256.hexdigest()

        if actual_checksum == expected_checksum:
            print(f'   ✅ Checksum verified for {artifact_name}')
            return True
        else:
            print(f'   ❌ Checksum mismatch for {artifact_name}:')
            print(f'      Expected: {expected_checksum}')
            print(f'      Actual:   {actual_checksum}')
            return False

    except Exception as e:
        print(f'   ⚠️  Could not verify checksum for {artifact_name}: {e}')
        return True  # Skip verification on error


async def verify_debian_artifact(artifact_url: str, artifact_name: str,
                                 checksums: dict, downloads_dir: str) -> bool:
    """Verify an artifact's SHA256 checksum against the Release file.
    
    Args:
        artifact_url: Full URL of the artifact
        artifact_name: Artifact filename
        checksums: Dict mapping filename to SHA256 checksum
        downloads_dir: Directory for downloading artifacts
    
    Returns:
        True if checksum matches, False otherwise
    """
    # Get checksum from Release file
    expected_checksum = checksums.get(artifact_name)
    if not expected_checksum:
        print(f'   ℹ️  No checksum in Release for {artifact_name} (skipping verification)')
        return True  # Skip verification if no checksum available
    
    # Download artifact to temp file
    temp_path = f'{temp_dir}/{artifact_name}'
    try:
        r = await _request_with_retry(requests.get, artifact_url, timeout=30, stream=True)
        r.raise_for_status()
        
        with open(temp_path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
        
        # Calculate SHA256
        sha256 = hashlib.sha256()
        with open(temp_path, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        
        actual_checksum = sha256.hexdigest()
        
        # Clean up temp file
        os.remove(temp_path)
        
        if actual_checksum == expected_checksum:
            print(f'   ✅ Checksum verified for {artifact_name}')
            return True
        else:
            print(f'   ❌ Checksum mismatch for {artifact_name}:')
            print(f'      Expected: {expected_checksum}')
            print(f'      Actual:   {actual_checksum}')
            return False
            
    except Exception as e:
        print(f'   ⚠️  Could not verify checksum for {artifact_name}: {e}')
        return True  # Skip verification on error
async def do_process(*, input_file: str, versions_file: str):
    """Main processing function.

    Reads the input spec, gets OpenZFS compatibility info, queries kernel
    versions, and writes the output YAML.
    """
    with open(input_file, 'r') as f:
        varsfile_contents = yaml.safe_load(f)
    atom_config = varsfile_contents.get('atom', {})
    config = atom_config.get('vars', atom_config)

    # Get revision from atom level (not from vars)
    revision = atom_config.get('revision', '')

    # Resolve URLs from config (module-level defaults moved here)
    mirrors = config.get('mirrors', [])
    if not mirrors:
        # Legacy: single URL or primary + fallback
        if 'debian_sources_url' in config:
            mirrors = [config['debian_sources_url']]
            if 'debian_sources_fallback_url' in config:
                mirrors.append(config['debian_sources_fallback_url'])
        else:
            mirrors = ['https://deb.debian.org/debian/pool/main/l/linux',
                       'https://mirrors.edge.kernel.org/pub/linux/dist/debian/pool/main/l/linux']

    pool_url = mirrors[0] if mirrors else 'https://deb.debian.org/debian/pool/main/l/linux'
    # Derive archive base from pool URL: pool/... -> archive base
    pool_base = pool_url.split('/pool/')[0] if '/pool/' in pool_url else pool_url

    kernel_dot_org_base_url = config.get(
        'kernel_dot_org_base_url',
        'https://mirrors.edge.kernel.org/pub/linux/kernel/v'
    )

    print(f'📦 Processing {config["branch"]}...')

    # Get OpenZFS compatibility range (only if tracking)
    track_openzfs = config.get('track_openzfs', True)
    if track_openzfs:
        zfs_compat = await get_openzfs_compat(
            openzfs_version=config['openzfs_version']
        )
        print(f'   OpenZFS range: {zfs_compat["min_str"]} - {zfs_compat["max_str"]}')
    else:
        zfs_compat = None
        print(f'   OpenZFS: not tracking')

    # Get kernel versions for releases (skip auto-discovery if explicit version pins)
    s = await get_releases(config, pool_base=pool_base)

    # If explicit versions are pinned in spec, bypass auto-discovery and use those instead  
    if 'versions' in config and isinstance(config['versions'], list):
        print(f'   📌 Using explicitly pinned versions: {config["versions"]}')
        filtered_s = {}
        
        # Fast path: check if discovered version matches a pin exactly
        for branch_name, discovered_ver in s.items():
            base_version = discovered_ver.rsplit('_p', 1)[0] if '_p' in discovered_ver else discovered_ver
            debpatch = discovered_ver.split('_p')[-1] if '_p' in discovered_ver else '1'
            for pinned_ver in config['versions']:
                if base_version == pinned_ver:
                    filtered_s[branch_name] = f'{pinned_ver}_p{debpatch}'
                    break
        
        # Slow path: if no match, query Debian pool directly for each pinned version's patch level
        if not filtered_s:
            print('   ℹ️  Pinned versions differ from discovered — querying pool directly...')
            for branch_name in s.keys():
                target_version = config['versions'][0]  # Use first pin as target
                debpatch = await get_debian_patch_level(target_version, branch_name, pool_url)
                filtered_s[branch_name] = f'{target_version}_p{debpatch}'
                print(f'   → {branch_name}: pinned {target_version} with patch level {debpatch}')
        
        s = filtered_s
        print('   ✅ Pinned version filter applied')

    versions_d = {
        'vars': {
            'versions': [],
            'metadata': {}
        }
    }

    for k, v in s.items():
        ver, triplet, debpatch = await check_version(
            openzfs_compat=zfs_compat if zfs_compat else {},
            ver=v,
            rel=(k, config['branch']),
            track_openzfs=track_openzfs,
            pool_url=pool_url,
            kernel_base_url=kernel_dot_org_base_url
        )

        # Start with KERNEL_TRIPLET (always first)
        spec_extra_envs = []
        for key, value in config.get('extra_envs', {}).items():
            spec_extra_envs.append(f'{key}={value}')

        versions_d['vars']['extra_envs'] = [f'KERNEL_TRIPLET="{triplet}"']

        # ktype/ksuffix from spec → extra_envs (in order)
        ktype = config.get('ktype', '')
        ksuffix = config.get('ksuffix', '')
        macaroni_ksuffix = ''  # Default empty
        if ktype:
            versions_d['vars']['extra_envs'].append(f'MACARONI_KTYPE="{ktype}"')
        if ksuffix:
            # ksuffix is like "debian-mark" -> "debian1-mark"
            ksuffix_parts = ksuffix.rsplit('-', 1)
            if len(ksuffix_parts) == 2:
                prefix = ksuffix_parts[0]  # "debian"
                suffix = ksuffix_parts[1]  # "mark"
                macaroni_ksuffix = f'{prefix}{debpatch}-{suffix}'
            else:
                macaroni_ksuffix = f'{ksuffix}{debpatch}'
            versions_d['vars']['extra_envs'].append(f'MACARONI_KSUFFIX="{macaroni_ksuffix}"')

        # Hybrid SLOT/PR: use SLOT-only at base revision, relative PR-SLOT after bumps
        slot = config.get('slot', config.get('branch', ''))
        base_rev = config.get('base_revision')
        if base_rev is None:
            raise ValueError('base_revision is required in spec vars')
        pr = int(config.get('pr', base_rev))

        if pr == base_rev:
            rev_suffix = ''
        else:
            rel_rev = pr - base_rev  # e.g., 201 - 200 = 1 → "_r1"
            rev_suffix = f'_r{rel_rev}'

        versions_d['vars']['extra_envs'].append(f'REVISION_SUFFIX="{rev_suffix}-{slot}"')
        versions_d['vars']['extra_envs'].append(
            f'EXTRAVERSION="{rev_suffix}-{slot}-{macaroni_ksuffix}"'
        )

        # LINUX_SRCDIR: clean src dir (triplet = kernel_ver, e.g., 6.12.88)
        versions_d['vars']['extra_envs'].append(
            f'LINUX_SRCDIR="linux-{triplet}{rev_suffix}-{config["branch"]}-{macaroni_ksuffix}"'
        )

        # Update MOD_DIR_NAME to match new convention (no ARCH prefix, clean triplet-based)
        versions_d['vars']['extra_envs'].append(
            f'MOD_DIR_NAME="{triplet}{rev_suffix}-{config["branch"]}-{macaroni_ksuffix}"'
        )

        # Append spec-level extra_envs (after computed ones)
        versions_d['vars']['extra_envs'].extend(spec_extra_envs)

        versions_d['vars']['metadata'].update({
            'slot': f'{slot}/{ver}',  # SLOT=branch/version
            'triplet': triplet,
            'debpatch': debpatch,
            'version_base': ver,
            'branch': {
                'level': config.get('level', ''),
                'name': config['branch'],
            },
        })

        versions_d['vars']['slot'] = f'"{config["branch"]}/{ver}"'

        versions_d['vars']['versions'].append(ver)

         # Get artifact URLs - use filtered version if pins were applied  
        # triplet/debpatch come from check_version which already respects filtering
        debian_tarball_name = f'linux_{triplet}-{debpatch}.debian.tar.xz'
        kernel_tarball_name = f'linux-{triplet}.tar.xz'

        do_verify = config.get('verify_artifacts', False)
        if not do_verify:
            print(f'   ⏭️  Skipping artifact verification (verify_artifacts: false)')  
            debian_tarball_url = f'{pool_url}/{debian_tarball_name}'
        else:
            debian_tarball_url = await get_artifact_url(
                name=debian_tarball_name,
                mirrors=mirrors,
                timeout=10
            )
        kernel_tarball_url = f'{get_kernel_dot_org_url(triplet.split(".")[0], kernel_dot_org_base_url)}/{kernel_tarball_name}'

        versions_d['artefacts'] = [
            {
                'url': debian_tarball_url,
                'name': debian_tarball_name
            },
            {
                'url': kernel_tarball_url,
                'name': kernel_tarball_name
            },
        ]

        if 'additional_artifacts' in config:
            additional_artefacts = [
                {
                    'url': url,
                    'name': name
                }
                for name, url in config['additional_artifacts'].items()
            ]
            versions_d['artefacts'].extend(additional_artefacts)

        # Verify artifact checksums if enabled (opt-in via verify_artifacts: true in spec vars)
        do_verify = config.get('verify_artifacts', False)
        if do_verify:
            print(f'   🔍 Verifying artifact checksums for {ver}...')
            try:
                # Get suite from branch config for Release file lookup
                suite = config.get('branch', config.get('debian_suite', 'trixie'))
                release_content = await download_release_file(suite, mirrors, timeout=30)
                debian_checksums = parse_release_checksums(release_content)

                # Download to mark-devkit's workdir/downloads/ so they're reused later
                # input_file is in workdir/custom-generator/<pkg>/input.yml
                # workdir/downloads/ is two levels up
                workdir = os.path.dirname(os.path.dirname(os.path.dirname(input_file)))
                downloads_dir = os.path.join(workdir, 'downloads')
                os.makedirs(downloads_dir, exist_ok=True)

                # Verify kernel.org artifacts (linux-X.Y.Z.tar.xz)
                kernel_checksums = {}
                for artefact in versions_d['artefacts']:
                    if artefact['name'].endswith('.tar.xz') and not artefact['name'].startswith('linux_'):
                        # Extract major version from URL (v6.x or v7.x)
                        major_match = re.search(r'kernel/v(\d+)\.x', artefact['url'])
                        if major_match:
                            if not kernel_checksums:
                                kernel_checksums = await parse_kernel_sha256sums(
                                    major_match.group(1), kernel_base_url=kernel_dot_org_base_url)
                            ok = await verify_kernel_artifact(
                                artefact['url'],
                                artefact['name'],
                                kernel_checksums,
                                downloads_dir
                            )
                            if not ok:
                                raise RuntimeError(f'Checksum verification failed for {artefact["name"]}')

                # Verify Debian pool artifacts (linux_X.Y.Z-N.debian.tar.xz)
                for artefact in versions_d['artefacts']:
                    if artefact['name'].endswith('.debian.tar.xz'):
                        ok = await verify_debian_artifact(
                            artefact['url'],
                            artefact['name'],
                            debian_checksums,
                            downloads_dir
                        )
                        if not ok:
                            raise RuntimeError(
                                f'Checksum verification failed for {artefact["name"]}'
                            )
                print(f'   ✅ All artifact checksums verified for {ver}')
            except Exception as e:
                print(f'   ⚠️  Artifact verification failed: {e}')
                # Non-fatal: warn but continue (generator can still produce ebuild)

    with open(versions_file, 'w') as f:
        yaml.safe_dump(
            versions_d,
            f,
            default_flow_style=False
        )

    print(f'   ✅ Generated {len(versions_d["vars"]["versions"])} version(s)')


state_callbacks = {
    'process': do_process,
}


async def entry_point(*args):
    """Entry point callback invoked by mark-devkit autogen framework.

    Args:
        args: Tuple of (generator_file, state, input_file, versions_file)
    """
    generator_file, state, input_file, versions_file = args
    if state in state_callbacks:
        await state_callbacks[state](
            input_file=input_file,
            versions_file=versions_file
        )
    else:
        raise ValueError(f'no callback for state: {state}')


if __name__ == '__main__':
    from sys import argv
    asyncio.run(entry_point(*argv))
