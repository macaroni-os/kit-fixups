#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):
	json_dict = await hub.pkgtools.fetch.get_page("https://sourceforge.net/projects/ndiswrapper/best_release.json", is_json=True)
	release_dict = json_dict["release"]
	version = (re.search(f"ndiswrapper-([0-9.]*).tar.gz", release_dict["url"])).group(1)
	url = f"http://downloads.sourceforge.net/project/ndiswrapper/stable/ndiswrapper-{version}.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url)]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
