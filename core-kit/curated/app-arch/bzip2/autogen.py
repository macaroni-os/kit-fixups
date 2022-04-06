#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import os
import re

regex = r'(\d+(?:\.\d+)+)'


async def generate(hub, **pkginfo):
    download_url = "https://sourceware.org/pub/bzip2/"
    html = await hub.pkgtools.fetch.get_page(download_url)
    soup = BeautifulSoup(html, features='html.parser').find_all('a', href=True)

    tarballs = [a.get('href') for a in soup if '.tar.' in a.contents[0] and not a.contents[0].endswith('sig')]
    versions = [(Version(re.findall(regex, a)[0]), a) for a in tarballs if re.findall(regex, a)]
    latest = max(versions)

    artifact = hub.pkgtools.ebuild.Artifact(url=download_url+latest[1])
    await artifact.fetch()
    artifact.extract()
    makefile = os.path.join(artifact.extract_path, f"bzip2-{latest[0]}/Makefile-libbz2_so")
    with open(makefile, "r") as mf:
        lines = mf.readlines()
        for line in lines:
            if 'soname' in line and not line.startswith('#'):
                soname = line.split()[-2].split('so.')[1].split('.')[0]

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest[0],
        artifacts=[artifact],
        soname=soname,
    )
    ebuild.push()
