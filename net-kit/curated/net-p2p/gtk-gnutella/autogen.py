#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	json_data = await hub.pkgtools.fetch.get_page(
		f"https://sourceforge.net/projects/{app}/best_release.json", is_json=True
	)

	filename = json_data["release"]["filename"]
	url = f"http://downloads.sourceforge.net/{filename}"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url)]
	version = filename.split("/")[2]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
