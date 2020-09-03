#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(
		"https://gitlab.com/api/v4/projects/188557/repository/tags?search=RELEASE"
	)
	json_list = json.loads(json_data)
	tag = None
	for tag_data in json_list:
		tag = tag_data["name"]
		break
	url = f"https://gitlab.com/fetchmail/fetchmail/-/archive/{tag}/fetchmail-{tag}.tar.gz"
	version = tag.split("_")[1].replace("-", ".")
	final_name = f"fetchmail-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, tag=tag, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
