#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

def generate_artifact(soup, download_url, tar):
    return (version, hub.pkgtools.ebuild.Artifact(url=download_url + latest_release))


async def generate(hub, **pkginfo):
    name = pkginfo.get("name")
    url = f"http://download.netsurf-browser.org/{pkginfo['url_suffix']}/"
    regex = r'(\d+(?:\.\d+)+)'

    # Download list of files
    html = await hub.pkgtools.fetch.get_page(url)
    soup = BeautifulSoup(html, "html.parser").find_all("a", href=True)

    pkg = pkginfo.get('tar_name') or name

    latest_release = max([
        (Version(re.findall(regex, a.contents[0])[0]), a.contents[0]) for a in soup if pkg in a.contents[0]
    ])

    # workaround for metatools not doing the revisions properly on a version number like '3.10'
    # see https://bugs.funtoo.org/browse/FL-9547
    revision_info = pkginfo.get('revision')
    if isinstance(revision_info, dict):
        rev = revision_info.popitem()
        print(Version(rev[0]))
        if latest_release[0] == Version(rev[0]):
            revision = rev[1]
    else:
        revision = Version(revision_info)

    pkginfo['revision'] = revision

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest_release[0],
        artifacts=[hub.pkgtools.ebuild.Artifact(url=url+latest_release[1])],
    )
    ebuild.push()



#vim: ts=4 sw=4 noet
