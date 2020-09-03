#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://download.gnome.org/sources/cantarell-fonts/cache.json")
	json_list = json.loads(json_data)
	release = json_list[2]["cantarell-fonts"][-1]
	# tarfile format: release/filename
	tarfile = json_list[1]["cantarell-fonts"][release]["tar.xz"]
	url = f"https://download.gnome.org/sources/cantarell-fonts/{tarfile}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		tag=release,
		version=release,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=tarfile.split("/")[1])],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
