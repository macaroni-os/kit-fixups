#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "KhronosGroup"
	github_repo = "SPIRV-Headers"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	version_wanted = "1.5.4.raytracing.fixed"
	url_wanted = None
	url = None
	for tag in json_list:
		v = tag["name"].lstrip("v")
		if version_wanted in v:
			url_wanted = tag["tarball_url"]
		if "-rc" in v or "vulkan" in v or url is not None:
			continue
		version = v
		url = tag["tarball_url"]
	final_name_wanted = f'{pkginfo["name"]}-1.5.4_p1.tar.gz'
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

	if url_wanted != None:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version="1.5.4_p1",
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url_wanted, final_name=final_name_wanted)],
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
