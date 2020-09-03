#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "WayneD"
	github_repo = "rsync"
	tarball_name = "rsync"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag in json_list:
		if "pre" in tag["name"]:
			continue
		version = tag["name"][1:]
		url = tag["tarball_url"]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{tarball_name}-{version}.tar.gz")],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
