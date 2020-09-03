#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	user = "qbittorrent"
	repo = "qBittorrent"
	app = "qbittorrent"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags?search=RELEASE")
	json_list = json.loads(json_data)
	version = json_list[0]["name"].split("-", 1)[1]
	url = f"https://github.com/{user}/{repo}/archive/release-{version}.tar.gz"
	final_name = f"{app}-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()
