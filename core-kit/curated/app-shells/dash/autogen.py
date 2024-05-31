#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re


async def generate(hub, **pkginfo):
	base_url = f"http://gondor.apana.org.au/~herbert/dash/files"
	base_data = await hub.pkgtools.fetch.get_page(base_url)
	base_soup = BeautifulSoup(base_data, "lxml")
	release_pattern = re.compile("(dash-([\d\.]+)\.tar\.gz)")
	release_hrefs = base_soup.find_all("a", href=True)
	release_matches = [release_pattern.match(x.get("href")) for x in release_hrefs]
	release_matches = [x for x in release_matches if x]
	release_matches.sort(key=lambda x: generic.parse(x.group(2)))
	latest_release, latest_version = release_matches[-1].groups()
	url = f"{base_url}/{latest_release}"
	artifact = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		artifacts=[artifact],
	)
	ebuild.push()
