#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
    name = pkginfo['name']
    download_url=f"https://invisible-mirror.net/archives/{name}/tarballs/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)
    compression = '.bz2'

    releases = [a for a in soup if name in a.contents[0] and a.contents[0].endswith(compression)]
    versions = [(generic.parse(a.contents[0].split('lynx')[1].split('.tar')[0].replace('rel', 'post')), a.get('href')) for a in releases if re.findall(regex, a.contents[0])]
    latest = max([v for v in versions if not v[0].is_prerelease])
    print(latest[0])

    artifact = hub.pkgtools.ebuild.Artifact(url=download_url + latest[1])

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=str(latest[0]).replace('.post', '_p').replace('.dev', '_pre'),
        artifacts=[artifact],
        my_p=str(latest[0])
    )
    ebuild.push()


#vim: ts=4 sw=4 noet
