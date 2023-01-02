#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:[\.-]\d+)+)'

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

    # Find all the patches
    patches_url = download_url + latest[0].public + '/'
    html = await hub.pkgtools.fetch.get_page(patches_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

    patches = [(Version(re.findall(regex, a.get('href'))[0]), a.get('href')) for a in soup if re.findall(regex, a.contents[0]) and not 'asc' in a.get('href')]

    # Find the newest patch
    newest = max(patches)[0]

    patch_artifacts = [hub.pkgtools.ebuild.Artifact(url=patches_url + p[1]) for p in patches]

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest[0].public + '_p' + str(newest.post),
        revision={'6.4_p20221231' : '1'},
        artifacts=[stable_artifact] + patch_artifacts,
        patches=[p[1].split('.gz')[0] for p in patches] # a list of all the unzipped patch filenames
    )
    ebuild.push()


#vim: ts=4 sw=4 noet
