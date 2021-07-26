#!/usr/bin/env python3

import json

GLOBAL_DEFAULTS = {"cat": "x11-drivers"}


async def generate(hub, **pkginfo):
	name = pkginfo["name"]
	gitlab_id = pkginfo["gitlab_id"]
	json_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{gitlab_id}/repository/tags"
	)
	json_list = json.loads(json_data)
	if "tag_name" in pkginfo:
		tag_name = pkginfo["tag_name"]
	else:
		tag_name = name
	version = json_list[0]["name"][len(tag_name) :].lstrip("-")
	url = f"https://gitlab.freedesktop.org/xorg/driver/{name}/-/archive/{tag_name}-{version}/{name}-{tag_name}-{version}.tar.bz2"
	final_name = f"{name}-{version}-gitlab.tar.bz2"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		template="driver.tmpl",
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
