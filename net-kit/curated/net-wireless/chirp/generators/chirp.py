#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):

	pkginfo["homepage"] = "https://chirp.danplanet.com/ http://github.com/kk7ds/chirp"
	pkginfo["description"] = "A free, open-source tool for programming your radio."
	pkginfo["python_compat"] = "python3+" # As of v.20230319 needs to by <=3.10.

	dnl_page = await hub.pkgtools.fetch.get_page("https://trac.chirp.danplanet.com/download?stream=next")
	hub.pkgtools.model.log.debug(f"Download page URL: {dnl_page}")

	for a in BeautifulSoup(dnl_page, features="html.parser").find_all("a", href=True):
		v = re.search("(?<=chirp-)\d+(?=\.tar\.gz)", a["href"])
		if v is not None:
			version = v.group(0)
			href = a["href"]

	pkginfo["version"] = version
	url=f'https://archive.chirpmyradio.com/chirp_next/next-{pkginfo["version"]}/chirp-{pkginfo["version"]}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
