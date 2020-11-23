#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://code.videolan.org/api/v4/projects/videolan%2Flibplacebo/repository/tags", is_json=True
	)
	for tag in json_list:
		v = tag["name"].lstrip("v")
		if "-rc" in v:
			continue
		version = v
		break
	url = f"https://code.videolan.org/videolan/libplacebo/-/archive/v{version}/libplacebo-v{version}.tar.bz2"
	final_name = f'{pkginfo["name"]}-{version}.tar.bz2'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
