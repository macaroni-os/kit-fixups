#!/bin/bash
# need to set the following vars:
# triplet:str, like '6.10.4'
# patchlevel:str, like 'p1'

# need to scrape the HTML, or get the version from
#https://deb.debian.org/debian/pool/main/l/linux/
#with dirlisting-1
# or from here with 
# sed -nre 's/^linux-source (\d\.\d+\d+-\d+).*$'
# https://packages.debian.org/testing/allpackages?format=txt.gz

# can get the sources from kernel.org
# and the patches from debian

# so: need to determine the current version for each debian version:
# - sid
# - trixie
# - bookworm

# need to check the version compatible with openzfs
# if trixie > openzfs,
# use last version with debian patches in openzfs series

# then download the sources
# download the patches


# === A prototype follows. ===

declare -A releases
releases[unstable]=sid
releases[testing]=trixie
releases[stable]=bookworm


get_version() {
    rel=$1
    # The following downloads the package list, decompresses it, and prints the
    # kernel source package version.
    v1=$(curl "https://packages.debian.org/$rel/allpackages?format=txt.gz" 2>/dev/null \
        | zcat | sed -nre \
        's/^.*linux-source[[:space:]].*([[:digit:]]\.[[:digit:]]+\.[[:digit:]]+)-([[:digit:]]+).*/\1_p\2/p')

    # returns: 6.10.4_p1
    echo "$v1"
}


get_openzfs_compat() {
    local -n data_ref=$1
    # The following gets the version from the META file in the openzfs
    # repository:
    zfs_max=$(curl https://raw.githubusercontent.com/openzfs/zfs/master/META \
        2> /dev/null | \
        sed -nre 's/Linux-Maximum:[[:space:]]([[:digit:]]\.[[:digit:]])/\1/p')

    # returns: 6.10

    zfs_min=$(curl https://raw.githubusercontent.com/openzfs/zfs/master/META \
        2> /dev/null | \
        sed -nre 's/Linux-Minimum:[[:space:]]([[:digit:]]\.[[:digit:]])/\1/p')

    # returns: 4.19

    data_ref[min]=$zfs_min
    data_ref[max]=$zfs_max
}


main() {
    local -A zfs_compat
    #mapfile -d ' ' $zfs_compat < <(get_openzfs_compat zfs_compat)
    get_openzfs_compat zfs_compat

    # set here for debugging
    #zfs_compat[max]=6.9
    #zfs_compat[min]=6.5

    echo OpenZFS compatability range: "${zfs_compat[*]}"
    for rel in "${!releases[@]}"; do
        echo "Looking for $rel: ${releases[$rel]}..."
        v1="$(get_version $rel)"
        echo "  Found version $v1"
        check_version zfs_compat "$v1"
    done
}


check_version() {
    local -n data_ref2=$1
    local v1=$2
    ver=$(echo "$v1" | sed -nre \
        's/([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)_p([[:digit:]]+)/\1-\2\.debian\.tar\.xz/p')

    local -a v2
    mapfile -d ' ' v2 < <(echo "$v1" | sed -nre \
        's/([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)_p([[:digit:]]+)/\1 \2 \3 \4/p')

    local -a zfs_max
    mapfile -d ' ' zfs_max < <(echo "${data_ref2[max]}" | sed -nre \
        's/([[:digit:]]+)\.([[:digit:]]+)/\1 \2/p')

    local -a zfs_min
    mapfile -d ' ' zfs_min < <(echo "${data_ref2[min]}" | sed -nre \
        's/([[:digit:]]+)\.([[:digit:]]+)/\1 \2/p')

    # Compare v1 with v2; is $v2 greater than or equal to $v1?
    # (below just checks if $v1 begins with $v2)
    if (( v2[0] <= zfs_max[0] )) && \
        (( v2[1] <= zfs_max[1] )) && \
        ( (( v2[0] > zfs_min[0] )) || \
          ( (( v2[0] == zfs_min[0] )) && \
            (( v2[1] >= zfs_min[1] )) ) ); then
        echo "  Happy days!  Debian $rel kernel $ver compatible with OpenZFS"

    else
        echo "  Version $ver not compatible with OpenZFS!"
        # The following gets a list of versions working with openzfs and returns the
        # entry at the bottom, which should be the highest version with ascending sort

        v3=$(curl https://deb.debian.org/debian/pool/main/l/linux/ 2> /dev/null | \
            sed -nre \
            "s/^.*a href=\"(linux_${data_ref2[max]}\.[[:digit:]]+-[[:digit:]]+\.debian\.tar\.xz)\".*$/\1/p" | \
            tail -n1)
        echo "  Found zfs-compat version $v3"

        # returns: 6.9.12-1.debian.tar.xz
    fi
}


main

# vim: syn=bash noet ts=4
