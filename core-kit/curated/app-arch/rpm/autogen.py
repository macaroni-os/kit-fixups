#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:\.\d+)+)'

async def generate(hub, **pkginfo):
    base_url = "http://ftp.rpm.org/releases/"
    html = await hub.pkgtools.fetch.get_page(base_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

    newest = max([(
            Version(re.findall(regex, a.get('href'))[0]),
            a.get('href')
        )
        for a in soup if a.contents[0].startswith(pkginfo['name'])
    ])

    download_url = base_url + newest[1]
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

    latest = max([(
            Version(re.findall(regex, a.contents[0])[0]),
            a.get('href')
        ) for a in soup if '.tar.' in a.contents[0]
    ])

    artifact = hub.pkgtools.ebuild.Artifact(url=f"{download_url}/{latest[1]}")
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest[0],
        artifacts=[artifact],
    )
    ebuild.push()
