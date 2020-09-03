#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	libgphoto_json = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/gphoto/libgphoto2/releases")
	json_list = json.loads(libgphoto_json)
	vtag = json_list[0]["tag_name"]
	version = vtag.lstrip("v")
	url = f"https://github.com/gphoto/libgphoto2/archive/{vtag}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url),]
	)
	ebuild.push()
