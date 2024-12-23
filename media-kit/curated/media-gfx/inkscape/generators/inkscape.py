#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import os
import re

regex = r'(\d+(?:\.\d+)+[a-z]*(?:\d*))'


async def generate(hub, **pkginfo):
    base_url = "https://inkscape.org/"
    download_url = base_url + "release/all/source/archive/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, features='html.parser').find_all('a', href=True)

    tarballs = [a.get('href') for a in soup if '.tar.' in a.contents[0] and not a.contents[0].endswith('sig')]
    versions = [(generic.parse(re.findall(regex, a)[0]), a) for a in tarballs if re.findall(regex, a)]

    version = []
    if 'version' in pkginfo:
        version = [generic.parse(pkginfo['version'])]
        del pkginfo['version']
        try:
            versions = dict(versions)
            version.append(versions[version[0]])
        except:
            print(version[0], 'not found in:', versions)
            return False
    else:
        version = max([v for v in versions if not v[0].is_prerelease])

    artifact = hub.pkgtools.ebuild.Artifact(url=base_url+version[1])

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version[0],
        artifacts=[artifact],
    )
    ebuild.push()
