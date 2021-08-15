#!/usr/bin/env python3

import glob
import os
from datetime import datetime


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)

def get_version(json):
	for tag in json:
		v = tag["name"].lstrip("v")
		if v.upper().isupper():
			continue
		version = v.replace("_",".")
		url = tag["tarball_url"]
		break
	return version, url

async def generate(hub, **pkginfo):
	github_user = "PixarAnimationStudios"
	github_repo = "OpenSubdiv"
	json_data = await query_github_api(github_user, github_repo, "tags")
	version, url = get_version(json_data)
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
