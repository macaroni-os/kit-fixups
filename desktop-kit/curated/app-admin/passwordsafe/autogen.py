#!/usr/bin/env python3

import json
from re import match

def get_latest_linux_version(releases):
	linux_releases = list(filter(lambda x: match(r"^PasswordSafe Linux release .+", x), releases))
	linux_releases.sort()
	return linux_releases.pop().split("release ").pop()

async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/pwsafe/pwsafe/releases")
	json_dict = json.loads(json_data)
	version = get_latest_linux_version(list(map(lambda x: x['name'], list(filter(lambda x: x['prerelease'] == False, json_dict)))))
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		hub,
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f'https://github.com/pwsafe/pwsafe/archive/{version}.tar.gz')
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
