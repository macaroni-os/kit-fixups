#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "KhronosGroup"
	github_repo = "OpenCL-Headers"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag in json_list:
		if "-rc" in tag["name"]:
			continue
		version = tag["name"].lstrip("v")
		url = tag["tarball_url"]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{app}-{version}.tar.gz")],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
