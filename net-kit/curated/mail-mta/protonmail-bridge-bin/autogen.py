#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	url = "https://protonmail.com/download/current_version_linux.json"
	json = await hub.pkgtools.fetch.get_page(url, is_json=True)
	rpm = json["RpmFile"]
	version = json["Version"]
	final_name = f'{pkginfo["name"]}-{version}.rpm'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=rpm, final_name=final_name)],
	)
	ebuild.push()
