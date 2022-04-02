#!/usr/bin/env python3

from datetime import datetime, timedelta


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)


async def generate(hub, **pkginfo):
	github_user = pkginfo.get("user")
	github_repo = pkginfo.get("repo") or pkginfo.get("name")
	pinned_commit = pkginfo.get("pinned_commit")
	pinned_version = pkginfo.get("pinned_version")
	commits = await query_github_api(github_user, github_repo, "commits")
	target_commit = commits[0]
	commit_date = datetime.strptime(target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	commit_hash = target_commit["sha"]
	version = f"{commit_date.strftime('%Y%m%d')}"
	if pinned_commit:
	   commit_hash = pinned_commit
	if pinned_version:
	    version = pinned_version
	url = f"https://github.com/{github_user}/{github_repo}/tarball/{commit_hash}"
	final_name = f"{github_repo}-{version}-{commit_hash}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

