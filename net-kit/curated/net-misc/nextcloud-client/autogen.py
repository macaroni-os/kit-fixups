#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	github_user = 'nextcloud'
	github_repo = 'desktop'
	json_data = await hub.pkgtools.fetch.get_page(f'https://api.github.com/repos/{github_user}/{github_repo}/tags')
	json_dict = json.loads(json_data)
	for tag in json_dict:
		if tag['name'].find("-beta") == -1:
			version = tag['name']
			break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version[1:], # [1:] slices out the 'v' char in version
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f'https://github.com/{github_user}/{github_repo}/archive/{version}.tar.gz', final_name=f'{github_user}-{version[1:]}.tar.gz')
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
