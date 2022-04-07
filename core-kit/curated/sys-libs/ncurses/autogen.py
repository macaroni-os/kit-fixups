#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:\.\d+)+)'

async def generate(hub, **pkginfo):
    download_url="https://invisible-mirror.net/archives/ncurses/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)


    releases = [a for a in soup if 'ncurses' in a.contents[0] and not a.contents[0].endswith('asc')]
    latest = max([(
            Version(re.findall(regex, a.contents[0])[0]),
            a.get('href'))
        for a in releases if re.findall(regex, a.contents[0])
    ])
    pkginfo['soname'] = latest[0].major

    stable_artifact = hub.pkgtools.ebuild.Artifact(url=download_url + latest[1])

    # generate stable ebuild
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest[0],
        artifacts=[stable_artifact],
        stable=True,
    )
    ebuild.push()

    next_url = download_url + latest[0].public


#vim: ts=4 sw=4 noet
