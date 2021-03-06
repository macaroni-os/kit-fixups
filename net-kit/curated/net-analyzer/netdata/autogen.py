#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	github_user = "netdata"
	github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	for rel in json_list:
		version = rel["tag_name"]
		if rel["draft"] == False and rel["prerelease"] == False:
			break

	version = version.lstrip("v")
	url = f"https://github.com/{github_user}/{github_repo}/releases/download/v{version}/{github_user}-v{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat="python3+",
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
