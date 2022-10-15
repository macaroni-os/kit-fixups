#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):

	release_data = await hub.pkgtools.fetch.get_page( pkginfo['dir']['url'], is_json=False )
	releases = re.findall(
		f'(?<=href="{pkginfo["name"]}-)\d+\.\d+\.\d+(?=\.tar\.gz"|\.tar\.bz2"|\.tar\.xz|\.zip")',
		release_data
	)

	version = releases[-1]
	url = f"{pkginfo['dir']['url']}{pkginfo['name']}-{version}.{pkginfo['dir']['format']}"

	artifact = hub.pkgtools.ebuild.Artifact(url=url)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact],
	)
	ebuild.push()


# vim: sw=4 ts=4 noet
