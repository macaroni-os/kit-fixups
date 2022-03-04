#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re
import os.path
import copy

pkg_metadata = {
    'ell': { 'cat': 'dev-libs', 'uri': 'libs/ell'},
    'bluez': { 'cat': 'net-wireless', 'uri': 'bluetooth' },
    'iwd': { 'cat': 'net-wireless', 'uri': 'network/wireless' }
}

async def get_latest_version(hub, **pkginfo):
    name = pkginfo['name']
    download_url = "https://mirrors.edge.kernel.org/pub/linux/" + pkg_metadata[name]['uri']

    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, features="html.parser")

    latest = max(
        [(a.text.split('-')[1].split('.tar')[0], a.text) for a in soup.findAll("a") if re.search(f"{name}-([0-9.]+).tar.xz", a.text)],
        key=lambda x: Version(x[0])
    )

    return (latest[0], hub.pkgtools.ebuild.Artifact(url=os.path.join(download_url,latest[1])))


async def generate(hub, **pkginfo):
    pkgs = {}
    # First cycle:
    #   1. build a dictionary of package_name -> pkginfo object based on the pkg_metadata
    #   2. fetch the latest version
    #   3. create the artifact for the latest version
    for pkg in pkg_metadata:
        pkgs[pkg] = copy.deepcopy(pkginfo)
        pkgs[pkg]['name'] = pkg
        pkgs[pkg]['cat'] = pkg_metadata[pkg]['cat']

        pkgs[pkg]['version'], pkg_metadata[pkg]['artifacts'] = await get_latest_version(hub, **pkgs[pkg])

    # Record the version of the ell package, since the other two require the latest
    ell_version = pkgs['ell']['version']

    # Traverse through the dictionary of pkginfos and generate ebuilds.  send the ell_version to all
    for pkg in pkgs:
        artifacts = pkg_metadata[pkg]['artifacts']
        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkgs[pkg],
            artifacts=[artifacts],
            ell_version=ell_version,
        )
        ebuild.push()
