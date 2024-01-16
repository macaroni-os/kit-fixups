#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

async def generate(hub, **pkginfo):
    releases_page = "https://support.google.com/earth/answer/168344"
    regex = r'(\d+(?:\.\d+)+)'

    html = await hub.pkgtools.fetch.get_page(releases_page)
    soup = BeautifulSoup(html, features="html.parser").find_all("a")

    debs = [a.get('href') for a in soup if a.has_attr('href') and a.get('href').endswith('deb')]
    latest_release = max([(Version(re.findall(regex, a)[0]), a) for a in debs])
    revision = { "7.3.6": "1" }

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest_release[0],
        revision=revision,
        artifacts=[hub.pkgtools.ebuild.Artifact(url=latest_release[1])],
    )
    ebuild.push()



#vim: ts=4 sw=4 noet
