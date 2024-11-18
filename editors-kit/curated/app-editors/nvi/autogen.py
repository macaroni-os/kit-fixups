#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

async def generate(hub, **pkginfo):
    #homepage = "https://sites.google.com/a/bostic.com/keithbostic/vi"
    homepage = "https://mirror.csclub.uwaterloo.ca/MacPorts/mpdistfiles/nvi/"
    regex = r'(\d+(?:\.\d+)+)'

    html = await hub.pkgtools.fetch.get_page(homepage)
    soup = BeautifulSoup(html, features="html.parser").find_all("a")

    downloads = [homepage+a.get('href') for a in soup if len(a) and "/" not in a.get('href')]
    latest = max([(generic.parse(re.findall(regex, a)[0]), a) for a in downloads])
    version = latest[0]
    if version.base_version == '1.81.6': revision = 8


    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        revision=revision,
        artifacts=[hub.pkgtools.ebuild.Artifact(url=latest[1])],
    )
    ebuild.push()



#vim: ts=4 sw=4 noet
