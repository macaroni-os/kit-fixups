#!/usr/bin/env python3

import json
from re import match


async def generate(hub, **pkginfo):
	github_user = "obsproject"
	github_repo = "obs-studio"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if "draft" in release and release["draft"] is not False:
			continue
		if "prerelease" in release and release["prerelease"] is not False:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	browser_repo = "obs-browser"
	browser_commits = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{browser_repo}/commits", is_json=True
	)
	browser_target_commit = browser_commits[0]
	browser_target_hash = browser_target_commit["sha"]
	browser_url = f"https://github.com/{github_user}/{browser_repo}/archive/{browser_target_hash}.tar.gz"
	browser_final_name = f"{browser_repo}-{browser_target_hash}.tar.gz"
	browser_artifact = hub.pkgtools.ebuild.Artifact(url=browser_url)
	cef_dir = "cef_binary_4280_linux64"
	cef_url = f"https://cdn-fastly.obsproject.com/downloads/{cef_dir}.tar.bz2"
	cef_artifact = hub.pkgtools.ebuild.Artifact(url=cef_url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		cef_dir=cef_dir,
		artifacts=[src_artifact, browser_artifact, cef_artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
