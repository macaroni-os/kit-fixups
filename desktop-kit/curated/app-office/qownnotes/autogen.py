#!/usr/bin/env python3

from metatools.version import generic
from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	tuxfamily_url = "https://download.tuxfamily.org/qownnotes/src"
	src_pattern = re.compile(f"^({pkginfo.get('name')}-([\\d.]+)\\.tar\\.xz)$")

	tuxfamily_soup = BeautifulSoup(
		await hub.pkgtools.fetch.get_page(tuxfamily_url), features="xml")

	link_matches = (
		src_pattern.match(link.get("href")) for link in tuxfamily_soup.find_all("a")
	)
	valid_matches = (match.groups() for match in link_matches if match)

	target_filename, target_version = max(
		valid_matches, key=lambda match: generic.parse(match[1])
	)
	src_url = f"{tuxfamily_url}/{target_filename}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
	)
	ebuild.push()

