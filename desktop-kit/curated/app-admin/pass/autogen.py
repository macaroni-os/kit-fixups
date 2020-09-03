#!/usr/bin/env python3

import json
from re import match


def get_latest_version(releases):
	releases.sort()
	return releases.pop()


async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/zx2c4/password-store/tags")
	json_dict = json.loads(json_data)
	version = get_latest_version(list(map(lambda x: x["name"], json_dict)))
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f"https://git.zx2c4.com/password-store/snapshot/password-store-{version}.tar.xz")
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
