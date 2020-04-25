#!/usr/bin/env python3

import json
from re import match

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/pwsafe/pwsafe/releases")
	json_list = json.loads(json_data)
	version = json_list[0]["tag_name"]
	url = f'https://github.com/pwsafe/pwsafe/archive/{version}.tar.gz'
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
