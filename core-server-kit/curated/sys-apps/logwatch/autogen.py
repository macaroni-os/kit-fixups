#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	json_data = await hub.pkgtools.fetch.get_page(f"https://sourceforge.net/projects/{app}/best_release.json", is_json=True)
	version = json_data["release"]["filename"].split(".tar")[0].split("-")[-1]
	url = f"http://downloads.sourceforge.net/{app}/{app}-{version}/{app}-{version}.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url)]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
