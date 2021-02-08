#!/usr/bin/env python3
from datetime import datetime, timedelta


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)


async def is_valid(user, repo, commit):
	commit_sha = commit["sha"]
	commit_status = await query_github_api(user, repo, f"commits/{commit_sha}/status")

	return "failure" not in commit_status["state"]


async def generate(hub, **pkginfo):
	github_user = "Mange"
	github_repo = "rtl8192eu-linux-driver"

	commits = await query_github_api(github_user, github_repo, "commits?sha=realtek-4.4.x")

	valid_commits = (commit for commit in commits if await is_valid(github_user, github_repo, commit))

	target_commit = await valid_commits.__anext__()

	commit_date = datetime.strptime(target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	commit_hash = target_commit["sha"]
	version = commit_date.strftime("%Y%m%d")
	url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_hash}.tar.gz"
	final_name = f"{pkginfo['name']}-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()
