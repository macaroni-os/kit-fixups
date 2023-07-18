#!/usr/bin/python3

from bs4 import BeautifulSoup
import re
async def generate(hub, **pkginfo):
    homepage_url = "https://dev.mysql.com/downloads/mysql/"
    html = await hub.pkgtools.fetch.get_page(homepage_url)
    soup = BeautifulSoup(html, features="html.parser")
    versions = {
        "8.0" : {
            "keywords" : "*",
        },
        "8.1" : {
            "keywords" : ""
        }
    }
    for opt in soup.findAll("option"):
        major_minor = opt['value']
        if major_minor in versions.keys():
            found = re.match("([0-9.]+)", opt.text)
            if not found:
                continue
            version = found.groups()[0]
            artifacts = [
                hub.pkgtools.ebuild.Artifact(url=f"https://cdn.mysql.com/Downloads/MySQL-{major_minor}/mysql-boost-{version}.tar.gz")
            ]
            ebuild = hub.pkgtools.ebuild.BreezyBuild(
                **pkginfo,
                artifacts=artifacts,
                version=version,
                revision={ "8.0.28" : "1" },
                keywords=versions[major_minor]["keywords"]
            )
            ebuild.push()

