#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://gitlab.com/api/v4/projects/192693/repository/tags")
	json_list = json.loads(json_data)
	for tag in json_list:
		v = tag["name"].lstrip("v")
		if "-rc" in v:
			continue
		version = v
		break
	url = f"https://libvirt.org/sources/libvirt-{version}.tar.xz"
	urlpy = f"https://libvirt.org/sources/python/libvirt-python-{version}.tar.gz"
	python_compat = "python3+"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, python_compat=python_compat, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()

	ebuildpy = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		cat="dev-python",
		name="libvirt-python",
		python_compat=python_compat,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=urlpy)],
	)
	ebuildpy.push()


# vim: ts=4 sw=4 noet
