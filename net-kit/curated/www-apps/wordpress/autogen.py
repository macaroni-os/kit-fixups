#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://api.wordpress.org/core/version-check/1.7")
	json_dict = json.loads(json_data)
	version = json_dict["offers"][0].get("version")
	url = f"https://wordpress.org/wordpress-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
