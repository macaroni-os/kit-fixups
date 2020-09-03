#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "SSSD"
	github_repo = "sssd"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags")
	json_dict = json.loads(json_data)
	version = json_dict[0]["name"].split("-", 2)[1]
	ebuild_version = ".".join(version.split("_"))
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=ebuild_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{github_user}/{github_repo}/releases/download/{github_repo}-{version}/{github_repo}-{ebuild_version}.tar.gz"
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
