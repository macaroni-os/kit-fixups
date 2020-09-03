#!/usr/bin/env python3

import json
from re import match


async def generate(hub, **pkginfo):
	GITHUB_REPO = "Cura"
	GITHUB_USER = "Ultimaker"
	python_compat = "python3+"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/releases")
	json_dict = json.loads(json_data)
	for release in json_dict:
		if release["prerelease"] or release["draft"]:
			continue
		GITHUB_TAG = release["tag_name"]
		break
	version = GITHUB_TAG.lstrip("v")
	url = f"https://github.com/{GITHUB_USER}/{GITHUB_REPO}/archive/{GITHUB_TAG}.tar.gz"
	final_name = f"{GITHUB_REPO}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
