#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(
		"https://launchermeta.mojang.com/v1/products/launcher/6f083b80d5e6fabbc4236f81d0d8f8a350c665a9/linux.json", is_json=True
	)
	version = json_data["launcher-bootstrap"][0]["version"]["name"]
	json_manifest = await hub.pkgtools.fetch.get_page( json_data["launcher-bootstrap"][0]["manifest"]["url"], is_json=True )
	url = json_manifest["files"]["minecraft-launcher"]["downloads"]["raw"]["url"]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url,final_name=f"minecraft-launcher-{version}")]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
