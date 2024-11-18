#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup
from metatools.version import generic


async def generate(hub, **pkginfo):
    download_url = "https://download.nextcloud.com/server/releases/"
    regex = r'(\d+(?:\.\d+)+)'
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, "html.parser").find_all("a")

    downloads = [a.get('href') for a in soup if a.get('href').endswith('.tar.bz2') and not a.get('href').startswith('latest')]
    tarballs = [(generic.parse(re.findall(regex, a)[0]), a) for a in downloads if re.findall(regex, a)]
    major_versions = set([a[0].major for a in tarballs])

    for major_version in major_versions:
        latest = max([a for a in tarballs if a[0].major == major_version])

        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=latest[0],
            artifacts=[hub.pkgtools.ebuild.Artifact(url=download_url + latest[1])]
        )
        ebuild.push()
