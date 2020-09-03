#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	sha1 = "558fb963bc0fb6a508a147f184342ec8676ef1d8"
	version = "1.2.8.20200831"
	url = f"https://gitlab.gnome.org/GNOME/NetworkManager-pptp/-/archive/{sha1}/NetworkManager-pptp-{sha1}.tar.gz"
	final_name = f"networkmanager-pptp-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, sha1=sha1, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
