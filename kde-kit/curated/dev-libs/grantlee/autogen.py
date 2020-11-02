#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	
	github_user = "steveire"
	github_repo = "grantlee"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag in json_list:
		v = tag["name"].lstrip("v")
		if "-rc" in v:
			continue
		version = v
		url = tag["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
