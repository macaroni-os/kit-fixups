#!/usr/bin/env python3

from packaging import version
import re


async def query_github_api(user, repo, query):
    return await hub.pkgtools.fetch.get_page(
            f"https://api.github.com/repos/{user}/{repo}/{query}",
            is_json=True,
            )

async def generate(hub, **pkginfo):
    github_user = "mypaint"
    github_repo = pkginfo.get("name")
    json_data = await query_github_api(github_user, github_repo, "tags")

    versions = {}
    for tag in json_data:
        tag_name = tag["name"]
        try:
            reres = list(re.finditer(r"^v\d+\.\d+(\.\d*)?$", tag_name))
            if len(reres) != 1:
                continue
            version = reres[0].string[1:]
            major = re.findall(r"^\d+", version)[0]
            if major in versions:
                continue
            else:
                versions[major] = {"url": tag["tarball_url"],
                        "commit_sha": tag["commit"]["sha"], "version": version}
        except IndexError:
            continue

    for major,ver in versions.items():
        url = ver["url"]
        commit_sha = ver["commit_sha"]
        version = ver["version"]
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
                slot=major,
                revision={ "1.3.1" : "1" }
                )
        ebuild.push()
