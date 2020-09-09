#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	user = "arvidn"
	repo = "libtorrent"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	for release in json_list:
		if release["prerelease"]:
			continue
		if release["draft"]:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break
	final_name = f"{app}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
