#!/usr/bin/python3

GLOBAL_DEFAULTS = {}

from metatools.generator.common import common_init

async def generate(hub, **pkginfo):
	common_init(hub, pkginfo)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()


# vim: ts=4 sw=4 noet
