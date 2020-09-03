#!/usr/bin/env python3


async def generate(hub, **pkginfo):

	url = await hub.pkgtools.fetch.get_url_from_redirect("https://zoom.us/client/latest/zoom_x86_64.pkg.tar.xz")
	version = url.split("/")[-2]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name="zoom-%s_x86_64.pkg.tar.xz" % version)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
