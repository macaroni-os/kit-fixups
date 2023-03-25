#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
    name = pkginfo['name']
    download_url="https://dev.yorhel.nl/download/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)


    releases = [a for a in soup if name in a.contents[0] and not 'linux' in a.contents[0] and a.contents[0].endswith('gz')]
    latest = max([(
            Version(re.findall(regex, a.contents[0])[0]),
            a.get('href'))
        for a in releases if re.findall(regex, a.contents[0])
    ])

    artifact = hub.pkgtools.ebuild.Artifact(url=download_url + latest[1])

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest[0],
        artifacts=[artifact]
    )
    ebuild.push()


#vim: ts=4 sw=4 noet
