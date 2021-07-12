#!/usr/bin/python3

import dyne.org.funtoo.metatools.pkgtools as pkgtools

async def generate(hub, **pkginfo):
	pkgtools.pyhelper.expand_pydeps(pkginfo)
	version = pkginfo['version']
	artifact = pkgtools.ebuild.Artifact(url=f"https://launchpad.net/rapid/pyqt/{version}/+download/{pkginfo['name']}-{version}.tar.gz")
	ebuild = pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[artifact])
	ebuild.push()
