#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "nextcloud"
	github_repo = "desktop"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"][1:]
		url = release["tarball_url"]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=f"nextcloud-desktop-{version}.tar.gz")],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
