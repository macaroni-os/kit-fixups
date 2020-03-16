#!/usr/bin/env python3

async def generate(hub):

	url = await hub.pkgtools.fetch.get_url_from_redirect("https://zoom.us/client/latest/zoom_x86_64.pkg.tar.xz")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		hub,
		name="zoom-bin",
		cat="net-im",
		version=url.split("/")[-2],
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()

# vim: ts=4 sw=4 noet
