#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re
import os.path

async def generate(hub, **pkginfo):
    name = pkginfo['name'].replace('plus', '')

    version_url = "https://hylafax.sourceforge.io/download.php"
    download_url = f"https://download.sourceforge.net/{name}/"


    html = await hub.pkgtools.fetch.get_page(version_url)
    soup = BeautifulSoup(html, features="html.parser")

    latest = max(
        [(a.text.split('-')[1].split('.tar')[0], a.text) for a in soup.findAll("a") if re.search(f"{name}-([0-9.]+).tar.gz", a.text)],
        key=lambda x: generic.parse(x[0])
    )

    artifact = hub.pkgtools.ebuild.Artifact(url=f"{download_url}{latest[1]}")
    pkginfo['version'] = latest[0]

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        artifacts=[artifact]
    )
    ebuild.push()
