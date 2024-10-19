#!/usr/bin/env python3

from pathlib import Path

import requests


async def generate_for(hub, pkg_name, release_channel, stable, **pkginfo):
    url = "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    headers = {
        'User-Agent': 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0',
        'Connection': 'keep-alive',
    }
    response = requests.get(url, headers=headers)
    version = extract_version_from_header(response.headers)

    src_url = f"https://update.code.visualstudio.com/{version}/linux-x64/{release_channel}"

    artifact = hub.pkgtools.ebuild.Artifact(url=src_url, final_name=f"{pkginfo['name']}-{version}.tar.gz")
    await artifact.fetch()
    artifact.extract()
    unpack_path = Path(artifact.extract_path)
    src_path = next(unpack_path.iterdir())  # path to `VSCode-linux-x64`
    sh_paths = [path.relative_to(src_path) for path in src_path.rglob("*.sh")]
    so_paths = [path.relative_to(src_path) for path in src_path.rglob("*.so")]
    node_paths = [path.relative_to(src_path) for path in src_path.rglob("*.node")]
    # rg is for ctrl+shift+f
    rg = [path.relative_to(src_path) for path in src_path.rglob("rg")]
    artifact.cleanup()
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        channel=pkg_name,
        unmasked=stable,
        artifacts=[artifact],
        fperms_paths=sh_paths + so_paths + node_paths + rg,
        src_path_name=src_path.name,
    )
    ebuild.push()


import re


def extract_version_from_header(response_headers):
    """
    Extracts version from filename in Content-Disposition header.

    Parameters:
    - response_headers: Dictionary containing HTTP response headers.

    Returns:
    - version (str) if found, otherwise None.
    """
    # Step 1 & 2: Parse Content-Disposition to extract the filename
    content_disposition = response_headers.get('Content-Disposition')
    if not content_disposition:
        return None

    # Regular expression to match the filename with or without UTF-8 declaration
    filename_pattern = r"filename(?:\*=UTF-8''|)=([^;]+)"
    match = re.search(filename_pattern, content_disposition)

    if match:
        filename = match.group(1)
    else:
        return None  # No filename found

    # Step 3: Extract version from the filename
    # Assuming version format is x.x.x (adjust pattern as needed for other formats)
    version_pattern = r"(\d+(?:\.\d+)*)"
    version_match = re.search(version_pattern, filename)

    if version_match:
        return version_match.group(1)  # Return the matched version
    else:
        return None  # No version found in the filename


async def generate(hub, **pkginfo):
    await generate_for(hub, "code", "stable", True, **pkginfo)

# vim: ts=4 sw=4 noet
