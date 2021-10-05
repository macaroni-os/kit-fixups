#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	base_url = "https://www.pell.portland.or.us/~orc/Code/discount/"
	final_name, pkginfo["version"] = await hub.pkgtools.pages.iter_links(
		base_url=base_url,
		match_fn=lambda x: re.match(f"(discount-(.*)\\.tar\\.bz2)", x),
		fixup_fn=lambda x: x.groups(),
		first_match=True
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		base_url=base_url,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"{base_url}{final_name}", final_name=final_name)]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet

