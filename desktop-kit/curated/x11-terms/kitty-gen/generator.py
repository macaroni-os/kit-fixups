#!/usr/bin/env python3
from datetime import datetime, timedelta
from packaging import version


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)


def get_release(release_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()


async def is_commit_safe(user, repo, commit):
	commit_status = await query_github_api(user, repo, f"commits/{commit}/status")
	return "failure" not in commit_status["state"]


async def generate(hub, **pkginfo):
	user = "kovidgoyal"
	repo = "kitty"
	releases_data = await query_github_api(user, repo, "releases")
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"]
	commits_data = await query_github_api(user, repo, "commits")
	safe_commits = (commit for commit in commits_data if await is_commit_safe(user, repo, commit["sha"]))
	target_commit = await safe_commits.__anext__()
	commit_date = datetime.strptime(target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	commit_hash = target_commit["sha"]
	version += "." + commit_date.strftime("%Y%m%d")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version.lstrip("v"),
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"https://github.com/{user}/{repo}/archive/{commit_hash}.tar.gz")],
	)
	ebuild.push()
