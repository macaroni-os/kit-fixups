#!/usr/bin/env python3

import asyncio
import gzip
import re
import requests


openzfs_meta_url = 'https://raw.githubusercontent.com/openzfs/zfs/master/META'

# squish this with the release name in the middle and it'll be a url string
# NOTE: this source disappears from time to time
#debian_packages_url = [
#    'https://packages.debian.org/',
#    '',
#    '/allpackages?format=txt.gz'
#]

# alternative source, with many mirrors available for failover
debian_packages_url = [
    'https://deb.debian.org/debian/dists/',
    '',
    '/main/binary-all/Packages.gz'
]

# TODO: implement mirror failover

debian_sources_url = 'https://deb.debian.org/debian/pool/main/l/linux'
kernel_dot_org_url = 'https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x'

async def get_version(*, rel:str):
    # The following downloads the package list, decompresses it, and prints the
    # kernel source package version.
    #
    # Note: cannot use the hub.pkgtools.fetch.get_page(...) because it returns
    # the compressed content as a string, and we need bytes.  The string is
    # already encoded with 'gzip' and needs to be decoded... it's backwards :)
    url = debian_packages_url
    url[1] = rel
    r = requests.get(''.join(url))
    text = gzip.decompress(r.content)
    print(''.join(url))
    # prior package source
    #v1 = re.findall(
    #    'linux-source *\((\d\.\d+\.\d+)-(\d+)\)',
    #    str(text)
    #)

    # deb mirrors
    v1 = re.findall(
        'pool/main/l/linux/linux-source_((\d\.\d+\.\d+)-(\d+))_all\.deb',
        str(text)
    )
    #print(v1, f'{v1[-1][1][-1]}_p{v1[-1][2]}')

    # returns: 6.10.4_p1
    # NOTE: chooses the final list element, assuming it is greatest
    return f'{v1[-1][1]}_p{v1[-1][2]}'


async def get_openzfs_compat():
    #local -n data_ref=$1
    # The following gets the version from the META file in the openzfs
    # repository:
    r = await hub.pkgtools.fetch.get_page(openzfs_meta_url)
    #r = requests.get(openzfs_meta_url)
    zfs_max = re.findall(
        'Linux-Maximum: (\d\.\d+)',
        r #r.text
    )[0]

    # returns: 6.10

    zfs_min = re.findall(
        'Linux-Minimum: (\d\.\d+)',
        r #r.text
    )[0]

    # returns: 4.19

    return { 'max' : zfs_max, 'min' : zfs_min }


# Check kernel for needed support
def check_version(*, openzfs_compat:dict, ver:str, rel:tuple,
                  track_openzfs:bool=True):
    # split the kernel version, like ['6.10.4', '1']
    v = re.findall(
        '(\d+\.\d+\.\d+)_p(\d+)',
        ver
    )[0]

    # further split the kernel version, like ['6', '10', '4', '1']
    v2 = re.findall(
        '(\d+)\.(\d+)\.(\d+)_p(\d+)',
        ver
    )[0]

    branch, name = rel

    # no need to continue if don't care about openzfs for this version
    if not track_openzfs:
        print(
            f'  Escaping early with version {ver} ({name}) because we are not tracking OpenZFS.'
        )
        return ver, v[0], v[1]

    # split the openzfs versions
    zfs_max = re.findall(
        '(\d+)\.(\d+)',
        openzfs_compat['max']
    )[0]

    zfs_min = re.findall(
        '(\d+)\.(\d+)',
        openzfs_compat['min']
    )[0]

    # return value will look like '6.10.4_p1'
    ret=''

    # compare the kernel version with the zfs_compat range
    if (
        v2[0] <= zfs_max[0] and
        v2[1] <= zfs_max[1] and (
            v2[0] > zfs_min[0] or (
                v2[0] == zfs_min[0] and
                v2[1] >= zfs_min[1]
            )
        )
    ):
        print(
            f'  Happy days!  Debian {branch} kernel {ver} ({name}) compatible with OpenZFS'
        )
        ret = ver, v[0], v[1]

    else:
        print(f'  Version {ver} ({name}) not compatible with OpenZFS!')
        # The following gets a list of versions working with openzfs and returns the
        # entry at the bottom, which should be the highest version with ascending sort
        r = requests.get('')
        v3 = re.findall(
            f'a href=\"(linux_{openzfs_compat["max"]}\.\d+)-(\d+)\.debian\.tar\.xz\"',
            r.text
        )[0]
        print(f"  Found zfs-compat version {v3[0]}_p{v3[1]}")

        ret = f'{v3[0]}_p{v3[1]}', v3[0], v3[1]

        # returns: 6.9.12_p1

    return ret


def create_ebuild(*, pkginfo, version, artifacts):
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        artifacts=artifacts,
    )
    ebuild.push()


async def generate(hub, **pkginfo):
    # get the openzfs compatability range
    zfs_compat = await get_openzfs_compat()

    #tracked_releases = ['stable', 'testing', 'unstable']
    tracked_releases = list(pkginfo['branches'].keys())

    # make a dictionary like { 'testing' : '6.10.4_p1' }
    s = dict(
        zip(
            tracked_releases,
            await asyncio.gather(
                *[
                    get_version(rel=r)
                    for r in tracked_releases
                ]
            )
        )
    )

    print(zfs_compat)
    print(s)

    artifacts_base = [
        hub.pkgtools.ebuild.Artifact(url=u)
        for k,u in pkginfo['additional_artifacts'].items()
    ]

    # FIXME HACK: shouldn't refer explicitly to release level strings
    # remove sid if sid kernel version == trixie kernel version
    if s['unstable'] == s['testing']:
        del s['unstable']

    for k,v in s.items():
        # returns the current version if it passes checks, or an alternative
        ver, triplet, debpatch = check_version(
            openzfs_compat=zfs_compat,
            ver=v,
            rel=(k, pkginfo['branches'][k]['name']),
            track_openzfs = pkginfo['branches'][k]['track_openzfs']
        )

        # make a copy, so that we don't append to the outer list
        artifacts = list(artifacts_base)

        artifacts.append(
            hub.pkgtools.ebuild.Artifact(
                url=f'{debian_sources_url}/linux_{triplet}-{debpatch}.debian.tar.xz'
            )
        )

        artifacts.append(
            hub.pkgtools.ebuild.Artifact(
                # Alternative source:
                # url=f'{debian_sources_url}/linux_{triplet}_orig.tar.xz'
                url=f'{kernel_dot_org_url}/linux-{triplet}.tar.xz'
            )
        )

        if ver in pkginfo['revisions'].keys():
            ver += f"-r{pkginfo['revisions'][ver]}"

        pkginfo.update(
            {
                'triplet' : triplet,
                'debpatch' : debpatch,
                'branch' : {
                    'level' : k,
                    'name' : pkginfo['branches'][k]['name'],
                },
        #        'slot' : f"{ver}/{pkginfo['branches'][k]['name']}",
                'slot' : f"{pkginfo['branches'][k]['name']}/{ver}",
            }
        )
        create_ebuild(pkginfo=pkginfo, version=ver, artifacts=artifacts)

        #pkginfo.update(
        #    {
        #        'slot' : f"{pkginfo['branches'][k]['name']}/{ver}",
        #        'name' : f"debian-sources-{pkginfo['branches'][k]['name']}",
        #        'template' : 'debian-sources.tmpl',
        #    }
        #)
        #create_ebuild(pkginfo=pkginfo, version=ver, artifacts=artifacts)


# vim: ts=4 sw=4
