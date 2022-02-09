#!/usr/bin/python3

async def generate(hub, **pkginfo):
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		template="awscli-c.tmpl"
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
