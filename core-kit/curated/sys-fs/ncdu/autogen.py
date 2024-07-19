#!/usr/bin/env python3

from metatools.version import generic
from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	download_url = "https://dev.yorhel.nl/download"
	src_pattern = re.compile(f"^.*/({pkginfo.get('name')}-([\\d.]+)\\.tar\\.gz)$")

	download_soup = BeautifulSoup(
		await hub.pkgtools.fetch.get_page(download_url), "lxml"
	)
	link_matches = (
		src_pattern.match(link.get("href")) for link in download_soup.find_all("a")
	)

	valid_matches = list(match.groups() for match in link_matches if match)
	max_tup = None

	for tup in valid_matches:
		ver = generic.parse(tup[1])
		if max_tup is None or ver > max_tup[2]:
			max_tup = ( tup[0], tup[1], ver)

	target_filename, pkginfo['version'], v_obj = max_tup
	src_url = f"{download_url}/{target_filename}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
