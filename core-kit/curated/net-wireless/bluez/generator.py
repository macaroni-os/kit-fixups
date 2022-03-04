#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re
import os.path

ebuilds_to_generate = ['dev-libs/ell', 'net-wireless/bluez', 'net-wireless/iwd']

async def generate(hub, **pkginfo):
    download_url = "https://mirrors.edge.kernel.org/pub/linux/" + pkginfo.get('uri_path')
    name = pkginfo.get('name')

    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, features="html.parser")

    latest_version = max([a.text for a in soup.findAll("a") if re.search(f"{name}-([0-9.]+).tar.xz", a.text)], key=lambda x: Version(x.split('-')[1].split('.tar')[0]))

    print(latest_version)


    artifacts = [hub.pkgtools.ebuild.Artifact(url=os.path.join(download_url,latest_version))]
    print(artifacts)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        artifacts=artifacts,
        version=latest_version.split('-')[1].split('.tar')[0]
    )
    ebuild.push()

#    https://mirrors.edge.kernel.org/pub/linux/libs/ell/
#    https://mirrors.edge.kernel.org/pub/linux/bluetooth/
#    https://mirrors.edge.kernel.org/pub/linux/network/wireless/
