#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "wayland"
	repo = pkginfo["name"]
	project_path = f"{user}%2F{repo}"
	tags_dict = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags", is_json=True
	)
	for tag in tags_dict:
		ver=tag["name"].split(".").pop()
		if ver != "0":
			continue
		version = tag["name"]
		break
	artifact = hub.pkgtools.ebuild.Artifact(url=f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive/{version}/{repo}-{version}.tar.bz2")

	wayland = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact],
	)
	wayland.push()

	scanner = hub.pkgtools.ebuild.BreezyBuild(
		template_path=wayland.template_path,
		cat="dev-util",
		name="wayland-scanner",
		version=version,
		artifacts=[artifact],
	)
	scanner.push()
