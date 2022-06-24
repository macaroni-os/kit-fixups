#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	github_user = "libgeos"
	github_repo = pkginfo["name"]
	geos_sources = "https://download.osgeo.org/geos/"
	html_data = await hub.pkgtools.fetch.get_page(geos_sources)
	latest = re.findall(f'<a href="geos-([0-9.]*)\.tar.bz2', html_data)
	version = latest[-1]

	src_artifact = hub.pkgtools.ebuild.Artifact(url=f"{geos_sources}/{pkginfo['name']}-{version}.tar.bz2")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, github_user=github_user, github_repo=github_repo, artifacts=[src_artifact]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
