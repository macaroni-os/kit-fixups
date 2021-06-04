#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "avahe-kellenberger"
	github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases",
		is_json=True,
	)
	for release in json_list:
		# Nimdow is currently beta, when a stable version is released, prerelease should also be false
		# if release["prerelease"] or release["draft"]:
		if release["draft"]:
			continue
		version = release["tag_name"].lstrip("v")
		url = release["tarball_url"]
		final_name = f'{pkginfo["name"]}-{version}.tar.gz'
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()
