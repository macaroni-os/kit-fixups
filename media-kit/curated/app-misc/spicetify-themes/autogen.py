#!/usr/bin/env python3

from datetime import datetime, timedelta


async def generate(hub, **pkginfo):
    user = "morpheusthewhite"
    repo = pkginfo["name"]
    commit_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/commits/master", is_json=True, refresh_interval=timedelta(days=15))
    commit_hash = commit_data["sha"]
    commit_date = datetime.strptime(commit_data["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
    version = commit_date.strftime("%Y%m%d")
    final_name = f"{repo}-{version}.tar.gz"
    src_url = f"https://github.com/{user}/{repo}/archive/{commit_hash}.tar.gz"
    src_artifact = hub.pkgtools.ebuild.Artifact(url=src_url, final_name=final_name)
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version.lstrip("v"),
        github_repo=repo,
        artifacts=[src_artifact],
    )
    ebuild.push()
