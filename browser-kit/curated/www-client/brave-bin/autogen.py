#!/usr/bin/env python3

import json
from re import match

def get_latest_stable_version_for_desktop(releases):
	stable_desktop_releases = list(filter(lambda x: match(r"^Release Channel v[0-9.]+$", x), releases))
	stable_desktop_releases.sort()
	return stable_desktop_releases.pop().split('v').pop()

async def generate(hub):

	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/brave/brave-browser/releases")
	json_dict = json.loads(json_data)
	version = get_latest_stable_version_for_desktop(list(map(lambda x: x['name'], json_dict)))
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		hub,
		name="brave-bin",
		cat="www-client",
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f'https://github.com/brave/brave-browser/releases/download/v{version}/brave-v{version}-linux-x64.zip')
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
