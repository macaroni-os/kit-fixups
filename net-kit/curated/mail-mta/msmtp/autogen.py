#!/usr/bin/env python3

import re
import urllib.parse

async def generate(hub, **pkginfo):

	base_url = "https://marlam.de/msmtp/download/"
	relative_url, pkginfo["version"] = await hub.pkgtools.pages.iter_links(
		base_url=base_url,
		match_fn=lambda x: re.match("(.*msmtp-(.*)\\.tar\\.xz)", x),
		fixup_fn=lambda x: x.groups(),
		first_match=True
	)
	url = urllib.parse.urljoin(base_url, relative_url)
	final_name = url.split("/")[-1]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet

