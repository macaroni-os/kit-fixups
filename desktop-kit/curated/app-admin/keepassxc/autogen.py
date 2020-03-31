#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/keepassxreboot/keepassxc/releases")
	json_dict = json.loads(json_data)
	release = json_dict[0]
	version = release['tag_name']
	for asset in release["assets"]:
		if asset['content_type'] == 'application/x-xz':
			url = asset['browser_download_url']
			break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url)
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
