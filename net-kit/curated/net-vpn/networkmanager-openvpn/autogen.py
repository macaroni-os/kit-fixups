#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	json_list = await hub.pkgtools.fetch.get_page(
		"https://gitlab.gnome.org/api/v4/projects/1600/repository/tags", is_json=True
	)
	for tag in json_list:
		if tag["name"].endswith("-dev"):
			continue
		version = tag["name"]
		break
	url = f"https://gitlab.gnome.org/GNOME/NetworkManager-openvpn/-/archive/{version}/NetworkManager-openvpn-{version}.tar.gz"
	final_name = f"networkmanager-openvpn-{version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
