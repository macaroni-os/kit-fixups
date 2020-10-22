#!/usr/bin/python3

GLOBAL_DEFAULTS = {}

async def generate(hub, **pkginfo):
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
