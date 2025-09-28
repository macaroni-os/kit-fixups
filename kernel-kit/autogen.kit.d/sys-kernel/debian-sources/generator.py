#!/usr/bin/env python3

import asyncio
import gzip
import re
import requests
import yaml


# squish this with the release name in the middle and it'll be a url string
# NOTE: this source disappears from time to time; instead, use a repo mirror
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

# TODO: implement mirror failover, instead of using only one

debian_sources_url = 'https://deb.debian.org/debian/pool/main/l/linux'
kernel_dot_org_url = 'https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x'

# used to encode branches like _p{deb_patchlevel}{code}
branch_codes = {
    'bookworm' : '0',
    'trixie' : '1',
    'forky' : '2',
    'sid' : '999'
}

# filled by read_vars()
vars_d = {}


async def get_version(*, rel:str):
    # The following downloads the package list, decompresses it, and prints the
    # kernel source package version.

    url = debian_packages_url
    url[1] = rel
    r = requests.get(''.join(url))
    text = gzip.decompress(r.content)

    # prior package source
    #v1 = re.findall(
    #    'linux-source *\((\d\.\d+\.\d+)-(\d+)\)',
    #    str(text)
    #)

    # deb mirrors
    v1 = re.findall(
        'pool/main/l/linux/linux-source_((\d\.\d+\.\d+)[-](\d+))_all\.deb',
        str(text)
    )

    # returns: 6.12.38_p1
    # NOTE: chooses the final list element, assuming it is greatest
    return f'{v1[-1][1]}_p{v1[-1][2]}'


async def get_openzfs_compat(*, openzfs_meta_url:str):
    # get the zfs META file
    r = requests.get(openzfs_meta_url)

    # returns: 6.10
    zfs_max = re.findall(
        'Linux-Maximum: (\d\.\d+)',
        r.text
    )[0]

    # returns: 6.10
    zfs_min = re.findall(
        'Linux-Minimum: (\d\.\d+)',
        r.text
    )[0]

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
            f'  Escaping early with version {ver} ({name}) because we are not'
            f' tracking OpenZFS on branch {branch}.'
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
            f'🍰  Happy days!  Debian {branch} kernel {ver} ({name}) compatible with OpenZFS'
        )
        ret = ver, v[0], v[1]

    else:
        print(f'💣  Version {ver} ({name}) not compatible with OpenZFS!')
        # The following gets a list of versions working with openzfs and returns the
        # entry at the bottom, which should be the highest version with ascending sort
        r = requests.get('')
        v3 = re.findall(
            f'a href=\"(linux_{openzfs_compat["max"]}\.\d+)-(\d+)\.debian\.tar\.xz\"',
            r.text
        )[0]
        print(f"🍓  Found zfs-compat version {v3[0]}_p{v3[1]}")

        ret = f'{v3[0]}_p{v3[1]}', v3[0], v3[1]

        # returns: 6.9.12_p1

    return ret


async def get_releases(config:list):
    # tracked_releases = ['stable', 'testing', 'unstable']
    tracked_releases = [config['branch']]

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

    print(s)
    return s


async def do_process(*, input_file:str, versions_file:str):
    varsfile_contents = yaml.safe_load(open(input_file, 'r'))
    config = varsfile_contents['atom']['vars']

    # get the openzfs compatibility range
    zfs_compat = await get_openzfs_compat(
        openzfs_meta_url = config['openzfs_meta_url']
    )
    print(zfs_compat)

    s = await get_releases(config)

    # remove sid if sid kernel version == testing kernel version
    #if s['unstable'] == s['testing']:
    #    del s['unstable']

    versions_d = {
        'vars' : {
            'versions' : [],
            'metadata' : {}
        }
    }

    for k,v in s.items():
        # returns the current version if it passes checks, or an alternative
        ver, triplet, debpatch = check_version(
            openzfs_compat=zfs_compat,
            ver=v,
            rel=(k, config['branch']),
            track_openzfs = config['track_openzfs']
        )

        if 'revisions' in config:
            if ver in config['revisions'].keys():
                ver += f"-r{config['revisions'][ver]}"

        versions_d['vars']['metadata'].update(
            {
                'triplet' : triplet,
                'debpatch' : debpatch,
                'branch' : {
                    'level' : config['level'],
                    'name' : config['branch'],
                },
                'slot' : f"{config['branch']}/{ver}",#"{branch_codes[config['branch']]}",
            }
        )
        versions_d['vars']['versions'].append(f"{ver}{branch_codes[config['branch']]}")
        versions_d['artefacts'] = [
            {
                'url' : f'{debian_sources_url}/linux_{triplet}-{debpatch}.debian.tar.xz',
                'name' : f'linux_{triplet}-{debpatch}.debian.tar.xz'
            },
            {
                'url' : f'{kernel_dot_org_url}/linux-{triplet}.tar.xz',
                'name' : f'linux-{triplet}.tar.xz'
            },
            # add the additional artefacts
        ]

        if 'additional_artifacts' in config:
            additional_artefacts = [
                {
                    'url' : f'{url}',
                    'name' : f'{name}'
                }
                for name, url in config['additional_artifacts'].items()
            ]

            versions_d['artefacts'].extend(additional_artefacts)

    yaml.safe_dump(
        versions_d,
        open(versions_file, 'w'),
        default_flow_style = False
    )


state_callbacks = {
    'process' : do_process,
    #'set-version' : do_set_version,
}


async def entry_point(*args):
    generator_file, state, input_file, versions_file = args
    if state in state_callbacks.keys():
        print('doing state', state)
        await state_callbacks[state](
            input_file = input_file,
            versions_file = versions_file
        )
    else:
        raise ValueError('no callback for state', state)


if __name__ == '__main__':
    from sys import argv
    asyncio.run(entry_point(*argv))

# vim: ts=4 sw=4
