#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(f"https://www.kernel.org/releases.json", is_json=True)
	version = json_list["latest_stable"]["version"]
	major_ver = version.split(".")[0]
	sources = hub.pkgtools.ebuild.Artifact(
		url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/linux-{version}.tar.xz"
	)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[sources]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
