#!/usr/bin/env python3

import urllib.parse


async def generate(hub, **pkginfo):
	user = "ajak"
	repo = pkginfo["name"]
	project_path = urllib.parse.quote_plus(f"{user}/{repo}")
	tags_dict = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.com/api/v4/projects/{project_path}/repository/tags", is_json=True
	)
	version = tags_dict[0]["name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version.lstrip("v"),
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f"https://gitlab.com/{user}/{repo}/-/archive/{version}/{repo}-{version}.tar.gz")
		],
	)
	ebuild.push()
