#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup
from packaging.version import Version


async def generate(hub, **pkginfo):
	compression = "xz"
	src_url = f"http://ftp.midnight-commander.org/"
	regex = r'(\d+(?:\.\d+)+)'
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser").find_all("a", href=True)

	downloads = [a.get('href') for a in soup if a.get('href').endswith(compression)]
	versions = [(Version(re.findall(regex, a)[0]), a) for a in downloads if re.findall(regex, a)]
	latest = max(versions)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest[0],
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url + latest[1])],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
