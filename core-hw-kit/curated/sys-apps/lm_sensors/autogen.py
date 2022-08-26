#!/usr/bin/env python3
from datetime import datetime, timedelta


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)

async def generate(hub, **pkginfo):
    github_user = "lm-sensors"
    github_repo = "lm-sensors"

    tags = await query_github_api(github_user, github_repo, "tags")
    target_tag = tags[0]
    for tag in tags:
        if tag["name"].find("V-") == -1 and tag["name"].startswith("V"):
            target_tag = tag
            break

    tag_name = target_tag["name"]
    version = tag_name.replace("-", ".")[1:]
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version = version,
        artifacts = [hub.pkgtools.ebuild.Artifact(url=f"https://api.github.com/repos/{github_user}/{github_repo}/tarball/refs/tags/{tag_name}", final_name=f"lm_sensors-{version}.tar.gz")]
    )
    ebuild.push()
