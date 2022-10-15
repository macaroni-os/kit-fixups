#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):

	base_url="https://downloads.powerdns.com/releases/"

	release_data = await hub.pkgtools.fetch.get_page( base_url, is_json=False )
	releases = re.findall(
		f'(?<=href="{pkginfo["name"]}-)\d+\.\d+\.\d+(?=\.tar\.gz"|\.tar\.bz2"|\.tar\.xz")',
		release_data
	)

	version = releases[-1]
	url = f"{base_url}{pkginfo['name']}-{version}.tar.bz2"

	artifact = hub.pkgtools.ebuild.Artifact(url=url)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact],
	)
	ebuild.push()


# vim: sw=4 ts=4 noet
