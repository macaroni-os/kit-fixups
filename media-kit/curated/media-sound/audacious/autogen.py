#!/usr/bin/env python3


import re

async def generate(hub, **pkginfo):
	github_user = "audacious-media-player"
	github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag_data in json_list:
		tag_name = tag_data["name"]

		# check for if tags like "4.0.1-beta1" or "4.0.1-gtk3"
		non_release_match = re.search("([0-9.]+-)", tag_name)
		if non_release_match is not None:
			continue

		ver_match = re.search("([0-9.]+)", tag_name)
		version = ver_match.groups()[0]

		url = tag_data["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
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
