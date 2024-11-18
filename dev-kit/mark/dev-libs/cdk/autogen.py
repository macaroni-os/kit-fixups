#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
    name = pkginfo['name']

    download_url = f"https://invisible-mirror.net/archives/{name}/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

    releases = [a for a in soup if name in a.contents[0] and not 'perl' in a.contents[0] and not a.get('href').endswith('.asc')]

    latest = max([(
            generic.parse(re.findall(regex, a.contents[0])[0]),
            a.get('href'))
        for a in releases if re.findall(regex, a.contents[0])
    ])
    pkginfo['soname'] = latest[0].major

    print(latest[1])
    artifact = hub.pkgtools.ebuild.Artifact(url=download_url + latest[1])

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=f"{latest[0].base_version}.{str(latest[0].post)}",
        artifacts=[artifact]
    )
    ebuild.push()


#vim: ts=4 sw=4 noet
