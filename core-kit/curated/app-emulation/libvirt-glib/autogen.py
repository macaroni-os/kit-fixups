#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://gitlab.com/api/v4/projects/192672/repository/tags")
	json_list = json.loads(json_data)
	for tag in json_list:
		v = tag["name"].lstrip("v")
		if "-rc" in v:
			continue
		version = v
		break
	url = f"https://libvirt.org/sources/glib/libvirt-glib-{version}.tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
