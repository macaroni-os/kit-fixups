#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re
import os.path

async def generate(hub, **pkginfo):
    download_url = "https://www.postgresql.org/ftp/source/"
    name = pkginfo.get('name')

    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, features="html.parser")

    slots = [ 10, 11, 12, 13, 14 ]
    for slot in slots:
        pkginfo_local = pkginfo.copy()
        pkginfo_local['slot'] = slot
        if slot in pkginfo['slots']:
            pkginfo_local.update(pkginfo['slots'][slot])
        latest_version = max([a.text for a in soup.findAll("a") if re.search(f"v{slot}.([0-9.]+)", a.text)], key=lambda x: Version(x[1:]))

        artifact_url = f"https://ftp.postgresql.org/pub/source/{latest_version}/{name}-{latest_version[1:]}.tar.bz2"
        artifacts = [hub.pkgtools.ebuild.Artifact(url=artifact_url)]

        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo_local,
            artifacts=artifacts,
            version=latest_version[1:]
        )
        ebuild.push()
