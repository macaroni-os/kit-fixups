#!/usr/bin/env python3

from datetime import datetime, timedelta


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)


async def generate(hub, **pkginfo):
	github_user = "weibeld"
	github_repo = pkginfo["name"]

	commits = await query_github_api(github_user, github_repo, "commits?sha=master")
	target_commit = commits[0]

	commit_date = datetime.strptime(
		target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ"
	)
	commit_hash = target_commit["sha"]
	version = commit_date.strftime("%Y%m%d")
	url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_hash}.tar.gz"
	final_name = f"{pkginfo['name']}-{version}-{commit_hash}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		sha=commit_hash,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

