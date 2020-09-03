#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/keepassxreboot/keepassxc/releases")
	json_dict = json.loads(json_data)
	for r in json_dict:
		if "prerelease" in r and r["prerelease"] is True:
			continue
		release = r
		break
	version = release["tag_name"]
	url = f"https://github.com/keepassxreboot/keepassxc/releases/download/{version}/keepassxc-{version}-src.tar.xz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
