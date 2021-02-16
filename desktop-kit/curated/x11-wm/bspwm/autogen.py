#!/usr/bin/env python3

import json

github_user = "baskerville"
github_repo = "bspwm"


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags")
	tags = json.loads(json_data)
	for tag in tags:
		v = tag["name"]
		if "-rc" in v:
			continue
		version = v
		url = tag["tarball_url"]
		break
	template_args = dict(
		github_user=github_user,
		github_repo=github_repo,
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{github_repo}-{version}.tgz"),
		],
		**template_args,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
