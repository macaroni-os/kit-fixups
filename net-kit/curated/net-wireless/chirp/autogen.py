#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	html = await hub.pkgtools.fetch.get_page("https://trac.chirp.danplanet.com/chirp_daily/LATEST")
	version = (re.search(f"chirp-daily-([0-9]*).tar.gz", html)).group(1)
	url = f"https://trac.chirp.danplanet.com/chirp_daily/daily-{version}/chirp-daily-{version}.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url)]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, python_compat="python2_7", artifacts=artifacts)
	ebuild.push()


# vim: ts=4 sw=4 noet
