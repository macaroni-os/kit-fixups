#!/usr/bin/env python3

from datetime import datetime, timedelta


async def generate(hub, **pkginfo):
	github_user = "khvzak"
	github_repo = pkginfo["name"]

	latest_commit = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/commits/master",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)

	commit_hash = latest_commit["sha"]

	commit_date = datetime.strptime(
		latest_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ"
	)
	version = commit_date.strftime("%Y%m%d")

	src_url = (
		f"https://github.com/{github_user}/{github_repo}/archive/{commit_hash}.tar.gz"
	)
	final_name = f"{github_repo}-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		commit_hash=commit_hash,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url, final_name=final_name)],
	)
	ebuild.push()

