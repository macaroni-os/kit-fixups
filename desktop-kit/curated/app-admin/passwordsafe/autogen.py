#!/usr/bin/env python3

import json
from re import match


async def generate(hub, **pkginfo):
	json_list = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/pwsafe/pwsafe/releases", is_json=True)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		if "Linux" not in release["name"]:
			continue
		version = release["tag_name"]
		url = f"https://github.com/pwsafe/pwsafe/archive/{version}.tar.gz"
		final_name = f'{pkginfo["name"]}-{version}.tar.gz'
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
