#!/usr/bin/env python3

import re
import urllib.parse

async def generate(hub, **pkginfo):

	base_url=f"https://ftp.debian.org/debian/pool/main/c/ca-certificates/"

	versions = await hub.pkgtools.pages.iter_links(
		base_url=base_url,
		match_fn=lambda x: re.match(r"^ca-certificates_([0-9]+)_all\.deb$", x),
		fixup_fn=lambda x: x.groups()[0]
	)
	version = hub.pkgtools.pages.latest(versions)
	url = urllib.parse.urljoin(base_url, f"ca-certificates_{version}_all.deb")
	if version is None:
		print("Could not find a ca-certificates version.")
		return
	elif version == "20211016":
		version = f"{version}-r1"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()

# vim: ts=4 sw=4 noet

