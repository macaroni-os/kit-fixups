#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import glob
import os.path
import re


async def generate(hub, **pkginfo):
    user = "spice"
    repo = pkginfo["name"]
    project_path = f"{user}%2F{repo}"
    info_url = f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags"
    download_url = f"https://gitlab.freedesktop.org/{user}/{repo}"

    regex = r'(\d+(?:[\.-]\d+)+)'

    tag_dict = await hub.pkgtools.fetch.get_page(info_url, is_json=True)
    tags = dict([(Version(re.findall(regex, tag["name"])[0]), tag) for tag in tag_dict])

    version, info = max(t for t in tags.items() if not t[0].is_prerelease)
    commit = info['commit']['short_id']
    sources = info['release']['description'].split('[')[1:]
    for s in sources:
        data = s.split('](')
        if not (data[0].endswith('sig') or data[0].endswith('sum') or '.msi' in data[0]):
            source = data[1].split(')')[0]
            compression = source.split('.tar.')[1]
            break


    artifact = hub.pkgtools.ebuild.Artifact(
        url=f"{download_url}{source}",
        final_name=f"{repo}-{version}-{commit}.tar.{compression}"
    )

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        gitlab_user=user,
        gitlab_repo=repo,
        artifacts=[artifact],
    )
    ebuild.push()
