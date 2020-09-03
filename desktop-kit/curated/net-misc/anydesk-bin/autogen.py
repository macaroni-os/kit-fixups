#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	html = await hub.pkgtools.fetch.get_page("https://anydesk.com/en/downloads/linux")
	match = re.search(r"https://download.anydesk.com/linux/anydesk-(.\..\..)-amd64.tar.gz", html)
	url = match.group(0)  # the entire match
	version = match.group(1)  # just the version
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
