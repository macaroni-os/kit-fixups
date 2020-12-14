#!/usr/bin/env python3

import json
from re import match


async def generate(hub, **pkginfo):
	GITHUB_USER = "hashicorp"
	GITHUB_REPO = "vagrant"
	# json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/tags")
	# json_list = json.loads(json_data)
	# GITHUB_TAG = json_list[0]["name"]
	# version = GITHUB_TAG.lstrip("v")

	# This is a workaround for FL-7722 to lock the version to work with our current vagrant dependencies:
	version = "2.2.10"
	GITHUB_TAG = "v" + version
	url = f"https://github.com/{GITHUB_USER}/{GITHUB_REPO}/archive/{GITHUB_TAG}.tar.gz"
	final_name = f"{GITHUB_REPO}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
