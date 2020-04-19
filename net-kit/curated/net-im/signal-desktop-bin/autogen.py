#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://raw.githubusercontent.com/signalapp/Signal-Desktop/master/package.json")
	json_dict = json.loads(json_data)
	version = json_dict.get('version')
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f'https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop/signal-desktop_{version}_amd64.deb')
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
