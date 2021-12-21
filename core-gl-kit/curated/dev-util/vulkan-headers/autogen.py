#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "KhronosGroup"
	github_repo = "Vulkan-Headers"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100", is_json=True
	)

	for tag in json_list:
		tag_match = re.match("v([0-9.]+)", tag["name"])
		if not tag_match:
			continue
		version = tag_match.groups()[0]
		url = tag["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
