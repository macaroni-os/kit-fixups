#!/usr/bin/env python3

import re
import glob
import os

async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)


async def generate(hub, **pkginfo):
	github_user = "strukturag"
	github_repo = "libde265"
	json_data = await query_github_api(github_user, github_repo, "releases")
	for release in json_data:
		if release["prerelease"] or release["draft"]:
			continue
		tag_name = release["tag_name"]
		version = tag_name.lstrip("v")
		break
	json_data = await query_github_api(github_user, github_repo, "tags")
	my_tag = list(filter(lambda x: x["name"] == tag_name, json_data))[0]
	url = my_tag["tarball_url"]
	commit_sha = my_tag["commit"]["sha"]
	final_name = f'{pkginfo["name"]}-{version}-{commit_sha}.tar.gz'
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
