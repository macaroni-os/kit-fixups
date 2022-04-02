#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

async def generate(hub, **pkginfo):
	regex = r'(\d+(?:\.\d+)+)'
	download_url = "https://zlib.net/current/"
	html = await hub.pkgtools.fetch.get_page(download_url)
	soup = BeautifulSoup(html, "html.parser").find_all("a")

	tarball = max([(
			Version(re.findall(regex, a.contents[0])[0]),
			a.get('href'))
		for a in soup if re.findall(regex, a.contents[0])
	])

	artifacts = hub.pkgtools.ebuild.Artifact(url=download_url + tarball[1])

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=tarball[0],
		artifacts=[artifacts],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
