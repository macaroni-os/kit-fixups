#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "zerotier"
	github_repo = "ZeroTierOne"
	json_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_data:
		if release["draft"] is True or release["prerelease"] is True:
			continue
		version = release["tag_name"]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://api.github.com/repos/zerotier/ZeroTierOne/tarball/{version}",
				final_name=f"{github_user}-{version}.tar.gz",
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
