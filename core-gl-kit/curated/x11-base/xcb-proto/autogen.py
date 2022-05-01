#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	project = "xorg"
	user = "proto"
	repo = "xcbproto"
	project_path = f"{project}%2F{user}%2F{repo}"
	tags_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags", is_json=True
	)
	for tag in tags_data:
		ver = tag["name"].split("-")[-1]
		if ver.upper().isupper():
			continue
		version = ver
		break

	url = f"https://xorg.freedesktop.org/archive/individual/{user}/{pkginfo['name']}-{version}.tar.xz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
