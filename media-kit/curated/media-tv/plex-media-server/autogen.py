#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	plex_url = "https://plex.tv/api/downloads/5.json"
	plex_json = await hub.pkgtools.fetch.get_page(plex_url)
	json_dict = json.loads(plex_json)
	releases = json_dict["computer"]["Linux"]["releases"]
	urls = {}
	for release in releases:
		url = release["url"]
		if url.endswith("_amd64.deb"):
			urls["amd64"] = url
		elif url.endswith("_i386.deb"):
			urls["x86"] = url

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=re.findall(r"(\d+\.\d+\.\d+\.\d+)-.+", json_dict["computer"]["Linux"]["version"])[0],
		python_compat="python2_7",
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=urls["amd64"]),
			hub.pkgtools.ebuild.Artifact(url=urls["x86"]),
		]
	)
	ebuild.push()
