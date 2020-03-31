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
