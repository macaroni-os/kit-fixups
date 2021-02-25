#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	package_lines = await hub.pkgtools.fetch.get_page(
		"https://updates.signal.org/desktop/apt/dists/xenial/main/binary-amd64/Packages"
	)
	package_lines = package_lines.split("\n")
	for package_line in package_lines:
		if package_line.startswith("Version: "):
			version = package_line[9:].strip()
			break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop/signal-desktop_{version}_amd64.deb"
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
