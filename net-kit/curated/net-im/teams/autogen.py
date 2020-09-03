#!/usr/bin/env python3

import re

RELEASE = re.compile(r"Version: ([0-9.]+)")


async def generate(hub, **pkginfo):
	text_data = await hub.pkgtools.fetch.get_page(
		"https://packages.microsoft.com/repos/ms-teams/dists/stable/main/binary-amd64/Packages"
	)
	text_list = text_data.split("\n")
	version = None

	for text in text_list:
		found = RELEASE.search(text)
		if found:
			version = found.groups()[0]
			break

	if version:
		pkg_file = f"teams_{version}_amd64.deb"
		url = f"https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/{pkg_file}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
