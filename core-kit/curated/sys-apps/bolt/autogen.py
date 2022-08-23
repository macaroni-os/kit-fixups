#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	gitlab_id = 32
	json_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{gitlab_id}/releases",
		is_json=True
	)
	release = json_data[0]
	url = list(filter(lambda x: x["format"] == "tar.bz2", release["assets"]["sources"]))[0]["url"]
	version = pkginfo['version'] = release["tag_name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
