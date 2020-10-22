#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	user = "mono"
	repo = "linux-packaging-libgdiplus"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True)
	version = json_list[0]["name"].split(sep="/")[-1]
	url = f"https://download.mono-project.com/sources/{app}/{app}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
