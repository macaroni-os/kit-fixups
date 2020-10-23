#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	html = await hub.pkgtools.fetch.get_page("https://slack.com/downloads/linux")
	url = "https://downloads.slack-edge.com/linux_releases/slack-desktop-{version}-amd64.deb"
	match = re.search(r"<strong>Version ([0-9.]+)</strong>", html)
	if match is None:
		raise hub.pkgtools.ebuild.BreezyError("Couldn't find slack version.")
	version = match.group(1)
	url = url.format(version=version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
