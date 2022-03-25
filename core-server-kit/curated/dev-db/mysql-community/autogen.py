#!/usr/bin/python3

from bs4 import BeautifulSoup
import re
async def generate(hub, **pkginfo):
    homepage_url = "https://dev.mysql.com/downloads/mysql/"
    html = await hub.pkgtools.fetch.get_page(homepage_url)
    soup = BeautifulSoup(html, features="html.parser")
    for h in soup.findAll("h1"):
        found = re.search("MySQL Community Server ([0-9.]+)", h.text)
        if found:
            version = found.groups()[0]
            break
    artifacts = [
        hub.pkgtools.ebuild.Artifact(url=f"https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-boost-{version}.tar.gz")
    ]
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        artifacts=artifacts,
        version=version,
        revision={ "8.0.28" : "1" }
    )
    ebuild.push()

