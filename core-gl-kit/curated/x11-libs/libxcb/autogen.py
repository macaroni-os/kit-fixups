#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	pkginfo["python_compat"] = "python3+"

	project = "xorg"
	user = "lib"
	repo = "libxcb"

	project_path = f"{project}%2F{user}%2F{repo}"
	tags_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags",
		is_json=True,
	)

	version = pkginfo["version"] = tags_data[0]["name"].lstrip("libxcb-")

	url = f"https://xorg.freedesktop.org/archive/individual/{user}/{pkginfo['name']}-{version}.tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
