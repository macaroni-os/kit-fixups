#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	github_user = "wireshark"
	github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	for rel in json_list:
		version = rel["name"].replace("wireshark-", "")
		if 'tarball_url' in rel:
			url = rel['tarball_url']

		if version != "":
			break


	final_name = f"{github_repo}-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
