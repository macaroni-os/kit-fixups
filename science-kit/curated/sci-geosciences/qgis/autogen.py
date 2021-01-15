#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	github_user = "qgis"
	github_repo = "QGIS"
	download_page = "https://qgis.org/downloads"
	html = await hub.pkgtools.fetch.get_page(f"{download_page}")
	matches = re.findall(f'<a href="qgis-([0-9.]*).tar.bz2">', html)
	version = matches[-1]

	if version is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {pkginfo['name']}")
	src_artifact = hub.pkgtools.ebuild.Artifact(url=f"{download_page}/qgis-{version}.tar.bz2")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, github_user=github_user, github_repo=github_repo, artifacts=[src_artifact]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
