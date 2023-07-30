#!/usr/bin/env python3
from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
	name = pkginfo["name"]
	base_url = f"https://gmplib.org"
	download_url = f"{base_url}/download/{name}/"
	html = await hub.pkgtools.fetch.get_page(download_url)
	soup = BeautifulSoup(html, 'html.parser').find_all("a", href=True)

	artifacts = {}

	releases = [a for a in soup if name in a.contents[0] and a.contents[0].endswith('.xz')]
	latest = max([(
			Version(re.findall(regex, a.contents[0])[0]),
			a.get('href'))
		for a in releases if re.findall(regex, a.contents[0])
	])
	version = latest[0]

	artifacts = [ hub.pkgtools.ebuild.Artifact(url=download_url + latest[1]) ]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest[0],
		artifacts=artifacts,
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
