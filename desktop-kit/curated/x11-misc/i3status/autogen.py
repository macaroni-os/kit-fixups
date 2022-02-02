#!/usr/bin/env python3

from packaging import version
import re


async def query_github_api(user, repo, query):
    return await hub.pkgtools.fetch.get_page(
            f"https://api.github.com/repos/{user}/{repo}/{query}",
            is_json=True,
            )

async def generate(hub, **pkginfo):
    github_user = "i3"
    github_repo = pkginfo.get("name")
    json_data = await query_github_api(github_user, github_repo, "tags")
    for tag in json_data:
        tag_name = tag["name"]
        try:
            reres = list(re.finditer(r"^\d+\.\d+(\.\d*)?$", tag_name))
            if len(reres) != 1:
                continue
            version = reres[0].string
            url = tag["tarball_url"]
            commit_sha = tag["commit"]["sha"]
        except IndexError:
            continue
        break
    final_name = f'{pkginfo["name"]}-{version}-{commit_sha}.tar.gz'
    artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)


    source_artifact = hub.pkgtools.ebuild.Artifact(
            url=url, final_name=final_name
            )

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=version,
            artifacts=[artifact],
            github_user=github_user,
            github_repo=github_repo,
            )
    ebuild.push()
