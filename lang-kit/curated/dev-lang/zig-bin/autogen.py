#!/usr/bin/env python3

import re
from collections import OrderedDict

architecture_names = dict(
    x86_64='amd64',
    i386='x86',
    riscv64='riscv64',
    aarch64='arm64',
    armv7a='arm',
)

async def generate_version(hub, spec, **pkginfo):
    artifacts = OrderedDict()
    for k, v in spec.items():
        (arch, os, *_) = k.split('-') + [None]

        arch = architecture_names.get(arch)
        if arch is None:
            continue

        if os == 'linux':
            artifacts[arch] = hub.pkgtools.ebuild.Artifact(url=v['tarball'])

    # Development versions must be normalized
    #  0.10.0-dev.661+c10fdde5a -> 0.10.0.661
    dev = False
    version = spec['version']
    m = re.fullmatch(r'([0-9.]+)-dev\.(\d+)\+\w+', version)
    if m:
        dev = True
        version = "%s.%s" % m.groups()

    hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        artifacts=artifacts,
        dev=dev,
    ).push()

async def generate(hub, **pkginfo):
    versions = await hub.pkgtools.fetch.get_page('https://ziglang.org/download/index.json', is_json=True)

    releases = [tuple(map(int, k.split('.'))) for k in versions.keys() if k != 'master']
    last_release = '.'.join(map(str, max(releases)))
    versions[last_release]['version'] = last_release

    await generate_version(hub, versions['master'], **pkginfo)
    await generate_version(hub, versions[last_release], **pkginfo)
