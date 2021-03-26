#!/usr/bin/env python3

import json
import re

async def generate(hub, **pkginfo):
	json_list = await hub.pkgtools.fetch.get_page(
		"https://gitlab.isc.org/api/v4/projects/1/repository/tags", is_json=True
	)
	tag = None
	devbuild = re.compile("v\d+_\d*[13579]_\d+")
	for tag_data in json_list:
		if devbuild.match(tag_data["name"]):
			continue;
		tag = tag_data["name"]
		break
	version = tag.lstrip("v").replace("_", ".")
	url = f"https://downloads.isc.org/isc/bind9/{version}/bind-{version}.tar.xz"
	final_name = f"bind-{version}.tar.xz"
	#url = f"https://gitlab.isc.org/isc-projects/bind9/-/archive/{tag}/bind9-{tag}.tar.bz2"
	#final_name = f"bind-{version}.tar.bz2"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
