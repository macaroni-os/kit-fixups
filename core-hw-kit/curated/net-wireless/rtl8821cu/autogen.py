#!/usr/bin/env python3

from datetime import datetime, timedelta
import re
import base64


async def find_latest_repo(hub, github_user):
	repo_pattern = re.compile(
		f"^https://github.com/{github_user}/(.+)$", flags=re.MULTILINE
	)

	perma_readme_info = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/8821cu/readme",
		is_json=True,
	)
	perma_readme = base64.b64decode(perma_readme_info["content"]).decode("utf-8")

	repo_match = repo_pattern.search(perma_readme)
	if repo_match is None:
		raise hub.pkgtools.ebuild.BreezyError(
			"Can't find the latest repo for rtl8821cu"
		)

	return repo_match.group(1)


async def generate(hub, **pkginfo):
	user = "morrownr"
	repo = await find_latest_repo(hub, user)

	commits = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/commits",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)
	target_commit = commits[0]
	commit_date = datetime.strptime(
		target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ"
	)
	commit_hash = target_commit["sha"]

	version = commit_date.strftime("%Y%m%d")

	url = f"https://github.com/{user}/{repo}/archive/{commit_hash}.tar.gz"
	final_name = f"{pkginfo['name']}-{version}-{commit_hash}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=user,
		github_repo=repo,
		version=version,
		sha=commit_hash,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

