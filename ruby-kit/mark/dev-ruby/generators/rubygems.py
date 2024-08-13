#!/usr/bin/python3

GLOBAL_DEFAULTS = {}

async def generate(hub, **pkginfo):
	artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://rubygems.org/downloads/{pkginfo['name']}-{pkginfo['version']}.gem"
	)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[artifact])
	ebuild.push()

# vim: ts=4 sw=4 noet
