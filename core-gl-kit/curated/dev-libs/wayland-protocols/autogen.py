#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "wayland"
	repo = pkginfo["name"]
	project_path = f"{user}%2F{repo}"
	tags_dict = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags", is_json=True
	)
	version = tags_dict[0]["name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive/{version}/{repo}-{version}.tar.bz2")
		],
	)
	ebuild.push()
