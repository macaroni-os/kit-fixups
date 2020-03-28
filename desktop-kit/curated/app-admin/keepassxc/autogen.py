#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/keepassxreboot/keepassxc/tags")
	json_dict = json.loads(json_data)
	for release in json_dict:
		if "-" in release["name"]:
			continue
		else:
			version = release["name"]
			break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		hub,
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(hub, url=f'https://github.com/keepassxreboot/keepassxc/archive/{version}.tar.gz')
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
