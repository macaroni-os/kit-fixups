#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
    name = pkginfo['name']
    download_url = "http://links.twibright.com/download/"
    icon_url = "https://dashboard.snapcraft.io/site_media/appmedia/2018/07/links-graphics-xlinks-logo-pic.png"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)
    compression = '.bz2'

    releases = [a for a in soup if name in a.contents[0] and a.contents[0].endswith(compression)]
    latest = max([(
            generic.parse(re.findall(regex, a.contents[0])[0]),
            a.get('href'))
        for a in releases if re.findall(regex, a.contents[0])
    ])

    tarball_artifact = hub.pkgtools.ebuild.Artifact(url=download_url + latest[1])
    icon_artifact = hub.pkgtools.ebuild.Artifact(url=icon_url)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest[0],
        artifacts=[tarball_artifact, icon_artifact],
    )
    ebuild.push()


#vim: ts=4 sw=4 noet
