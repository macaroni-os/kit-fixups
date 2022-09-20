#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	base_url = "https://jwz.org/xscreensaver"
	html_data = await hub.pkgtools.fetch.get_page(base_url + "/download.html")
	latest = re.search("xscreensaver-([0-9.]*).tar.gz", html_data)
	version = latest.group(1)
	src_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/xscreensaver-{version}.tar.gz")
	artifacts = [
		src_artifact,
	]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			revision={ "6.05.1": "1" },
			artifacts=artifacts)
	ebuild.push()


# vim: ts=4 sw=4 noet
