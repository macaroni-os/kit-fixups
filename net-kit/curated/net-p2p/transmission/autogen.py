#!/usr/bin/env python3

import json
from packaging import version


async def generate(hub, **pkginfo):
	github_user = "transmission"
	github_repo = "transmission"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases",
		is_json=True,
	)

	json_list = sorted(json_list, key=lambda x: version.parse(x["tag_name"]), reverse=True)

	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		tag_name = release["tag_name"][0:]
		break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=tag_name,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/transmission/transmission-releases/raw/master/{app}-{tag_name}.tar.xz",
				final_name=f"{app}-{tag_name}.tar.xz",
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
