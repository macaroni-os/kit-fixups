#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	pkginfo["homepage"] = "https://chirp.danplanet.com/ http://github.com/kk7ds/chirp"
	pkginfo["description"] = "A free, open-source tool for programming your radio."
	pkginfo["python_compat"] = "python3+" # As of v.20230319 needs to by <=3.10.

	dnl_page = await hub.pkgtools.fetch.get_url_from_redirect("https://trac.chirp.danplanet.com/download?stream=next")
	hub.pkgtools.model.log.debug(f"Download page URL: {dnl_page}")

	match = re.search("\d{8}$", dnl_page)
	if not match:
		raise KeyError("Could not find a suitable version.")
	
	pkginfo["version"] = match[0]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, 
		artifacts=[hub.pkgtools.ebuild.Artifact(
			url=f'https://trac.chirp.danplanet.com/chirp_next/next-{pkginfo["version"]}/chirp-{pkginfo["version"]}.tar.gz'
			)
		]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
