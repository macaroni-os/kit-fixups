#!/usr/bin/env python

import re
from metatools.version import generic

async def generate(hub, **pkginfo):

	base_url = "https://dl.hexchat.net/hexchat/"

	versions = await hub.pkgtools.pages.iter_links (
		base_url = base_url,
		match_fn = lambda x: re.match("hexchat-(\d+\.\d+\.\d+).tar.xz", x),
		fixup_fn = lambda x: x.groups()[0]
    )

	versions.sort( key=lambda x: generic.parse(x), reverse=True )
	version = versions[0]
	hub.pkgtools.model.log.debug(f"Versions found: {versions}")
	hub.pkgtools.model.log.debug(f"Latest: {version}")

	artifact = hub.pkgtools.ebuild.Artifact(
		url=f'{base_url}/{pkginfo["name"]}-{version}.tar.xz'
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
