#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	gphoto_json = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/gphoto/gphoto2/releases")
	json_list = json.loads(gphoto_json)
	vtag = json_list[0]["tag_name"]
	version = str.join(".", re.findall(r"gphoto2-(\d+_\d+_\d+)", vtag)[0].split("_"))
	url = f"https://github.com/gphoto/gphoto2/archive/{vtag}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, vtag=vtag, artifacts=[hub.pkgtools.ebuild.Artifact(url=url),],
	)
	ebuild.push()
