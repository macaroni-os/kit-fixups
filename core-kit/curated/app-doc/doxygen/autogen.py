#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "doxygen"
	github_repo = "doxygen"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100", is_json=True
	)

	for tag in json_list:
		version = tag["name"]
		version = version.replace('_','.')
		version = version.lstrip("Release.")
		url = tag["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	print(version)
	print(final_name)

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

