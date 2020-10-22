#!/usr/bin/env python3

import yaml


async def generate(hub, **pkginfo):

	yaml_data = await hub.pkgtools.fetch.get_page("https://raw.githubusercontent.com/mono/website/gh-pages/_data/latestrelease.yml")
	yaml_list = yaml.load(yaml_data, Loader=yaml.SafeLoader)
	version = yaml_list["version"].split()[-1].strip("()")
	url = f"https://download.mono-project.com/sources/mono/mono-{version}.tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
