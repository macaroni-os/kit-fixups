#!/usr/bin/env python3
from datetime import datetime, timedelta
# HTML parser
from bs4 import BeautifulSoup

archive = ".src.rpm"
pkg_name = "hwinfo"
url_g = "https://download.opensuse.org/source/tumbleweed/repo/oss/src/"

async def get_latest_release(hub, **pkginfo):
    # Here we get the site, sorted by latest date on the top
    html = await hub.pkgtools.fetch.get_page(f"{url_g}?C=M&O=A")
    # Iterate all links in the page
    for a in BeautifulSoup(html, features="html.parser").find_all("a", href=True):
        href = a['href']
        # Check if the link begins with m17n-contrib, ends with .tar.gz and doesn't contain RC(Release Candidate) in the name
        if href.endswith(archive) and href.startswith(pkg_name) and href.find(".rc") == -1:
            return href

async def generate(hub, **pkginfo):
    result = await get_latest_release(hub, **pkginfo)
    
    # At the end there is a +1 because we need to remove the - before the version number
    version = result[:result.rfind("-")][len(pkg_name) + 1:] 
    url = f"{url_g}{result}"

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{pkg_name}-{version}.rpm")],
    )
    ebuild.push()


