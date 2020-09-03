#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "rclone"
	github_repo = "rclone"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags")
	json_dict = json.loads(json_data)
	version = json_dict[0]["name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version[1:],  # `[1:]` slices out the 'v' char from the version
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{github_user}/{github_repo}/releases/download/{version}/{github_repo}-{version}.tar.gz"
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
