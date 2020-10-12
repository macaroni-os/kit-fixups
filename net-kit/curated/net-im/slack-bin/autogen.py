#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	html = await hub.pkgtools.fetch.get_page("https://slack.com/downloads/instructions/debian")
	match = re.search(r"https://downloads\.slack-edge\.com/linux_releases/slack-desktop-([^-]+)-amd64.deb", html)
	if match is None:
		raise hub.pkgtools.ebuild.BreezyError("Couldn't find slack version.")
	url = match.group(0)
	version = match.group(1)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
