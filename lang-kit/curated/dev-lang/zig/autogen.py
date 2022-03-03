#!/usr/bin/env python3

import re
from collections import OrderedDict
from packaging.version import Version

ebuilds_to_generate = [ 'dev-lang/zig', 'dev-lang/zig-bin', 'virtual/zig', ]

architecture_names = dict(
    x86_64='amd64',
    i386='x86',
    riscv64='riscv64',
    aarch64='arm64',
    armv7a='arm',
)

async def generate_bin_artifacts(hub, spec, **pkginfo):
    artifacts = OrderedDict()
    for k, v in spec.items():
        (arch, os, *_) = k.split('-') + [None]

        arch = architecture_names.get(arch)
        if arch is None:
            continue

        if os == 'linux':
            artifacts[arch] = hub.pkgtools.ebuild.Artifact(url=v['tarball'])
    return artifacts

async def generate_src_artifacts(hub, spec, **pkginfo):
    return [hub.pkgtools.ebuild.Artifact(url=spec['src']['tarball'])]

async def generate_ebuild(hub, spec, artifacts='', **pkginfo):
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

    releases = [Version(k) for k in versions.keys() if k != 'master']
    last_release = (max(releases)).public # .public provides the version as a string instead of Version()
    versions[last_release]['version'] = last_release

    for v in ['master', last_release]:
        vers = versions[v]

        for catpkg in ebuilds_to_generate:
            cat, pkg = catpkg.split('/')

            if cat == 'virtual': template = cat
            else: template = pkg

            template = template + '.tmpl'

            if pkg.endswith('-bin'):
                artifacts = await generate_bin_artifacts(hub, vers, **pkginfo)
            else:
                artifacts = await generate_src_artifacts(hub, vers, **pkginfo)


            pkginfo['name'] = pkg
            pkginfo['cat']  = cat
            if template:
                pkginfo['template'] = template

            await generate_ebuild(hub, vers, artifacts=artifacts, **pkginfo)
