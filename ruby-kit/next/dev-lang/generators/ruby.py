#!/usr/bin/python3

GLOBAL_DEFAULTS = {}

from packaging import version

async def generate(hub, **pkginfo):
	v = version.parse(pkginfo['version'])
	release_version = f"{v.major}.{v.minor}"
	artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://cache.ruby-lang.org/pub/ruby/{release_version}/ruby-{pkginfo['version']}.tar.xz"
	)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[artifact])
	ebuild.push()

# vim: ts=4 sw=4 noet
