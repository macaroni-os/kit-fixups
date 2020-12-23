#!/usr/bin/env python3

# This autogen will generate both gphoto2 and libgphoto2.


async def generate(hub, **pkginfo):
	base_pkginfo = pkginfo
	for spec_pkginfo in [{"name": "gphoto2", "cat": "media-gfx"}, {"name": "libgphoto2", "cat": "media-libs"}]:
		pkginfo = base_pkginfo.copy()
		pkginfo.update(spec_pkginfo)
		json_list = await hub.pkgtools.fetch.get_page(
			f"https://api.github.com/repos/gphoto/{pkginfo['name']}/releases", is_json=True
		)
		version = None
		for release in json_list:
			# new versions seem to have tag "v2.5.6"
			vtag = release["tag_name"]
			if vtag.startswith("v"):
				version = vtag[1:]
				break
		if version is None:
			raise hub.pkgtools.ebuild.BreezyError("Could not find suitable version.")
		url = f"https://github.com/gphoto/{pkginfo['name']}/archive/{vtag}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			vtag=vtag,
			template=f"{pkginfo['name']}.tmpl",
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{pkginfo['name']}-{version}.tar.gz"),
			],
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
