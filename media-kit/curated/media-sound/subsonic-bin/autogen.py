#!/usr/bin/env python3

import re
import urllib.parse

async def generate(hub, **pkginfo):

	base_url = "http://www.subsonic.org/pages/download.jsp"
	relative_url, version = await hub.pkgtools.pages.iter_links(
		base_url=base_url,
		match_fn=lambda x: re.match("(.*subsonic-([0-9.]+)-standalone\\.tar\\.gz)", x),
		fixup_fn=lambda x: x.groups(),
		first_match=True
	)
	pkginfo["version"] = version
	user_url = urllib.parse.urljoin(base_url, relative_url)
	final_name = user_url.split("=")[-1]
	url = f"https://download.sourceforge.net/subsonic/{version}/{final_name}"
	print(url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet

