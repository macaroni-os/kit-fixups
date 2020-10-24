#!/usr/bin/python3

GLOBAL_DEFAULTS = {}


async def generate(hub, **pkginfo):
	artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://storage.googleapis.com/golang/go{pkginfo['version']}.src.tar.gz"
	)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[artifact])
	ebuild.push()


# vim: ts=4 sw=4 noet
