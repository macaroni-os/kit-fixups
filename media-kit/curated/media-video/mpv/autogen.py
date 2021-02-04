#!/usr/bin/env python3

from datetime import datetime, timedelta


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "mpv-player"
	github_repo = "mpv"
	waf_version = "2.0.20"
	json_data = await query_github_api(github_user, github_repo, "releases")
	for release in json_data:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"].lstrip("v")
		break
	commit_data = await query_github_api(github_user, github_repo, "commits/master")
	commit_hash = commit_data["sha"]
	commit_date = datetime.strptime(commit_data["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	version += "." + commit_date.strftime("%Y%m%d")
	url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_hash}.tar.gz"
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	waf_url = f"https://waf.io/waf-{waf_version}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat=python_compat,
		github_user=github_user,
		github_repo=github_repo,
		waf_version=waf_version,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
			hub.pkgtools.ebuild.Artifact(url=waf_url),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
