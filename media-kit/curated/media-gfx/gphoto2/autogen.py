#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	json_list = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/gphoto/gphoto2/releases", is_json=True)
	version = None
	for release in json_list:
		try:
			# new versions seem to have tag "v2.5.6"
			vtag = release["tag_name"]
			if vtag.startswith("v"):
				version = vtag[1:]
				break
			else:
				# old versions seem to have an annoying "gphoto2-2_3_1-release" tag.
				version = str.join(".", re.findall(r"gphoto2-(\d+_\d+_\d+)", vtag)[0].split("_"))
		except IndexError:
			print("Couldn't extract version info from", vtag)
			# regex fail
			continue
	if version is None:
		raise hub.pkgtools.ebuild.BreezyError("Could not find suitable version.")
	url = f"https://github.com/gphoto/gphoto2/archive/{vtag}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		vtag=vtag,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=f"gphoto2-{version}.tar.gz"),],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
