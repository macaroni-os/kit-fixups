#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	json_list = await hub.pkgtools.fetch.get_page(
		"https://gitlab.isc.org/api/v4/projects/1/repository/tags", is_json=True
	)
	for tag in json_list:
		minor = tag["name"].split("_")[1]
		if int(minor) % 2:
			continue
		version = tag["name"].lstrip("v").replace("_", ".")
		break
	url = f"https://downloads.isc.org/isc/bind9/{version}/bind-{version}.tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, python_compat=python_compat, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
