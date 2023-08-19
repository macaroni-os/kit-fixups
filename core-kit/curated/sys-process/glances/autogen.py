#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "nicolargo"
	github_repo = "glances"
	app = pkginfo["name"]
	python_compat = "python3+"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"].lstrip("v")
		url = f"https://github.com/{github_user}/{github_repo}/archive/v{version}.tar.gz"
		break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{app}-{version}.tar.gz")],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
