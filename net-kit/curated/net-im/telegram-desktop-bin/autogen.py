#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	json_list = await hub.pkgtools.fetch.get_page(
		"https://api.github.com/repos/telegramdesktop/tdesktop/releases", is_json=True
	)
	for release in sorted(json_list, key=lambda x: x["tag_name"].lstrip("v")):
		if release["prerelease"] or release["draft"]:
			continue
		for asset in release["assets"]:
			if asset["label"] == "Linux 64 bit: Binary" and asset["state"] == "uploaded":
				version = release["tag_name"].lstrip("v")
				url = asset["browser_download_url"]
				break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/telegramdesktop/tdesktop/archive/v{version}.tar.gz",
				final_name=f"tdesktop-{version}.tar.gz",
			),
			hub.pkgtools.ebuild.Artifact(url=url),
		],
	)
	ebuild.push()
