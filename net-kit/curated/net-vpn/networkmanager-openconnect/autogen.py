#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	sha1 = "7747070b387ee72c71f88999770925d941e28ab7"
	version = "1.2.6.20200831"
	component = "openconnect"
	url = f"https://gitlab.gnome.org/GNOME/NetworkManager-{component}/-/archive/{sha1}/NetworkManager-{component}-{sha1}.tar.gz"
	final_name = f"networkmanager-{component}-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, sha1=sha1, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
