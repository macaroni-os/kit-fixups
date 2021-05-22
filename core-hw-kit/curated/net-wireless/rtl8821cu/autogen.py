#!/usr/bin/env python3

from datetime import datetime, timedelta


async def generate(hub, **pkginfo):
	user = "brektrou"
	repo = "rtl8821CU"
	commits = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/commits", is_json=True, refresh_interval=timedelta(days=15))
	target_commit = commits[0]
	commit_date = datetime.strptime(target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	commit_hash = target_commit["sha"]
	version = commit_date.strftime("%Y%m%d")
	url = f"https://github.com/{user}/{repo}/archive/{commit_hash}.tar.gz"
	final_name = f"{pkginfo['name']}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=user,
		github_repo=repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()
