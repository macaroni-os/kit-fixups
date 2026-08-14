#!/bin/bash
# gcc-math-discover.sh — Custom extension for GCC autogen
# Downloads source tarball, extracts contrib/download_prerequisites, and parses
# exact GMP/MPFR/MPC versions required by each GCC release.

set -euo pipefail

input_file="$1"
output_file="$2"

name=$(yq4 e '.name' "$input_file")
version=$(yq4 e '.vars.version' "$input_file")
download_dir=$(yq4 e '.vars.download_dir' "$input_file" | sed 's/^"//;s/"$//')
mirror=$(yq4 e '.opts.mirror // .vars.mirror' "$input_file" | sed 's/^"//;s/"$//')
# Fallback if opts.mirror not populated by mark-devkit handler
[[ -z "$mirror" ]] && mirror="https://ftpmirror.gnu.org"

echo "gcc-math: discovering math packages for GCC ${version}" >&2

# Strip revision suffix (-rN) from version for tarball download
base_version="${version%%-r*}"
major="${version%%.*}"

# Download and parse contrib/download_prerequisites from source tarball
tarball_name="gcc-${base_version}.tar.xz"
tarball_path="${download_dir}/${tarball_name}"
prereq_url="${mirror}/gnu/gcc/gcc-${base_version}/gcc-${base_version}.tar.xz"

gmp_ver="" mpfr_ver="" mpc_ver=""
discovered=false

# ── Asset verification with SHA512 checksum cache ──

sha512_url="${mirror}/gnu/gcc/gcc-${base_version}/sha512.sum"
expected_sha512=""

# Try to get expected checksum from GNU mirror
if curl -fsSL --max-time 10 -o "${download_dir}/.sha512.sum.tmp" "$sha512_url" 2>/dev/null; then
    expected_sha512=$(grep " ${tarball_name}$" "${download_dir}/.sha512.sum.tmp" | awk '{print $1}')
    rm -f "${download_dir}/.sha512.sum.tmp"
fi

if [[ -n "$expected_sha512" ]]; then
    if [[ -f "$tarball_path" ]]; then
        actual_sha512=$(sha512sum "$tarball_path" | awk '{print $1}')
        if [[ "$actual_sha512" == "$expected_sha512" ]]; then
            echo "gcc-math: cached tarball verified (SHA512 match)" >&2
        else
            echo "gcc-math: cached tarball checksum mismatch, re-downloading" >&2
            rm -f "$tarball_path"
        fi
    fi

    # Download if not present or stale
    if [[ ! -f "$tarball_path" ]]; then
        echo "gcc-math: downloading ${prereq_url}" >&2
        if curl -fsSL --max-time 60 -o "${tarball_path}.partial" "$prereq_url" 2>/dev/null; then
            mv "${tarball_path}.partial" "$tarball_path"
            # Verify downloaded file
            actual_sha512=$(sha512sum "$tarball_path" | awk '{print $1}')
            if [[ "$actual_sha512" != "$expected_sha512" ]]; then
                echo "gcc-math: ERROR - downloaded tarball SHA512 verification failed" >&2
                rm -f "$tarball_path"
            else
                echo "gcc-math: downloaded tarball verified (SHA512 match)" >&2
            fi
        else
            echo "gcc-math: WARNING - download failed, will use fallback mapping" >&2
        fi
    fi
else
    # No checksum available — fall back to simple cache check
    if [[ -f "$tarball_path" ]]; then
        echo "gcc-math: cached tarball (no checksum available for verification)" >&2
    else
        echo "gcc-math: downloading ${prereq_url}" >&2
        curl -fsSL --max-time 60 -o "${tarball_path}.partial" "$prereq_url" 2>/dev/null \
            && mv "${tarball_path}.partial" "$tarball_path" || true
    fi
fi

if [[ -f "$tarball_path" ]]; then
    # Extract just contrib/download_prerequisites without full extraction
    if tar xf "$tarball_path" --wildcards 'gcc-'${base_version}'/contrib/download_prerequisites' 2>/dev/null; then
        prereq_file=$(find . -name 'download_prerequisites' -path "*/gcc-${base_version}/*" | head -1)
        if [[ -n "$prereq_file" ]]; then
            # Parse math package versions from the script
            gmp_ver=$(grep -oP '(?<=gmp-)[0-9]+\.[0-9]+\.[0-9]+' "$prereq_file" | head -1)
            mpfr_ver=$(grep -oP '(?<=mpfr-)[0-9]+\.[0-9]+\.[0-9]+' "$prereq_file" | head -1)
            mpc_ver=$(grep -oP '(?<=mpc-)[0-9]+\.[0-9]+\.[0-9]+' "$prereq_file" | head -1)

            # Clean up extracted file
            rm -rf "./gcc-${base_version}" 2>/dev/null || true

            if [[ -n "$gmp_ver" && -n "$mpfr_ver" && -n "$mpc_ver" ]]; then
                discovered=true
                echo "gcc-math: DISCOVERED GMP=${gmp_ver}, MPFR=${mpfr_ver}, MPC=${mpc_ver}" >&2
            fi
        fi
    fi
fi

# Fallback mapping for older versions or extraction failure
if [[ "$discovered" != true || -z "$gmp_ver" || -z "$mpfr_ver" || -z "$mpc_ver" ]]; then
    echo "gcc-math: ERROR — dynamic discovery failed, no fallback available" >&2
    exit 1
fi

echo "gcc-math: using GMP=${gmp_ver}, MPFR=${mpfr_ver}, MPC=${mpc_ver}" >&2

cat > "$output_file" <<EOF
vars:
  gmp_ver: ${gmp_ver}
  gmp_extraver: ""
  mpfr_ver: ${mpfr_ver}
  mpfr_patch_ver: ""
  mpc_ver: ${mpc_ver}
artefacts:
  - url: "${mirror}/gnu/gmp/gmp-${gmp_ver}.tar.xz"
    name: "gmp-${gmp_ver}.tar.xz"
    use: ""
  - url: "https://www.mpfr.org/mpfr-${mpfr_ver}/mpfr-${mpfr_ver}.tar.xz"
    name: "mpfr-${mpfr_ver}.tar.xz"
    use: ""
  - url: "${mirror}/gnu/mpc/mpc-${mpc_ver}.tar.gz"
    name: "mpc-${mpc_ver}.tar.gz"
    use: ""
EOF
