#!/usr/bin/env python3

import json
from re import match


async def generate(hub, **pkginfo):
	github_user = "obsproject"
	github_repo = "obs-studio"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if "draft" in release and release["draft"] is not False:
			continue
		if "prerelease" in release and release["prerelease"] is not False:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
