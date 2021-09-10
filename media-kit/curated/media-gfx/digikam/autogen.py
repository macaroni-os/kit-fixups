#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "graphics"
	repo = pkginfo["name"]
	project_path = f"231"
	tag_data = await hub.pkgtools.fetch.get_page(
		f"https://invent.kde.org/api/v4/projects/{project_path}/repository/tags", is_json=True
	)
	for tag in tag_data:
		version = tag["name"]
		break

	url = f"https://invent.kde.org/{user}/{repo}/-/archive/{version}/{repo}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version[1:],
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet