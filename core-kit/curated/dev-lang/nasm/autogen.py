#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):
	pkginfo['homepage'] = "https://www.nasm.us"
	
	versions = await hub.pkgtools.pages.iter_links (
		base_url=f"{pkginfo['homepage']}/pub/nasm/releasebuilds",
		match_fn=lambda x: re.match(f"(\d+(?:\.\d+)+)\/", x),
		fixup_fn=lambda x: x.groups()[0]
	)
	if not versions:
		hub.pkgtools.model.log.debug(versions)
		raise KeyError("Could not find any suitable release.")
	
	# Use this if you need to stop the autogen at a given version.
	# versions = ['2.16']

	pkginfo['version'] = hub.pkgtools.pages.latest(versions)

	hub.pkgtools.model.log.debug(f"Versions found: {versions}")
	hub.pkgtools.model.log.debug(f"Selected version: {hub.pkgtools.pages.latest(versions)}")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[ hub.pkgtools.ebuild.Artifact( url =
			f"{pkginfo['homepage']}/pub/nasm/releasebuilds/{pkginfo['version']}/nasm-{pkginfo['version']}.tar.xz"
		)]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
