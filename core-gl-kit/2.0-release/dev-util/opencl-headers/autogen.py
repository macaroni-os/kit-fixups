#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	wanted_version = "2020.12.18"
	github_user = "KhronosGroup"
	github_repo = "OpenCL-Headers"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	version = []
	url = []
	masked = True
	for tag in json_list:
		if "-rc" in tag["name"]:
			continue
		version.append(tag["name"].lstrip("v"))
		url.append(tag["tarball_url"])

	for v in [version[0], wanted_version]:
		if v == wanted_version:
			masked = False
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=v,
			masked=masked,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url[version.index(v)], final_name=f"{app}-{v}.tar.gz")],
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
