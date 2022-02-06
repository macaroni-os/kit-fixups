#!/usr/bin/env python3

import re
import urllib

async def generate(hub, **pkginfo):
	html_url = f"https://www.openal-soft.org"
	rel_path, version = await hub.pkgtools.pages.iter_links(
			base_url=html_url,
			match_fn=lambda x: re.match(f"(.*/openal-soft-([0-9.]+).tar.bz2)", x),
			fixup_fn=lambda x: x.groups(),
			first_match=True
	)
	dl_url = urllib.parse.urljoin(html_url, rel_path)
	artifacts = [hub.pkgtools.ebuild.Artifact(url=dl_url)]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
			version=version,
			artifacts=artifacts,
			**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet

