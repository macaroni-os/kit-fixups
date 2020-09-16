#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	json_list = await hub.pkgtools.fetch.get_page(
		"https://api.github.com/repos/telegramdesktop/tdesktop/releases", is_json=True
	)
	stable_releases = (
		(re.match("v ([\d\.]+)", item["name"]), item)
		for item in json_list
		if not item.get("prerelease")
		if not item.get("draft")
	)
	_, latest_release = max(stable_releases, key=lambda item: item[0].group(1))
	version = latest_release["name"][2:]
	url = next(
		(
			asset["browser_download_url"]
			for asset in latest_release["assets"]
			if asset["label"] == "Linux 64 bit: Binary"
			if asset["state"] == "uploaded"
		)
	)
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
