#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging import version
import re

async def generate(hub, **pkginfo):
	src_url = f"https://mirrors.edge.kernel.org/pub/software/utils/dtc/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "lxml")

	filename_pattern = re.compile("(dtc-([\d.]+).tar.xz)")
	link_matches = (filename_pattern.match(link.get("href")) for link in soup.find_all("a"))
	valid_matches = (match.groups() for match in link_matches if match)
	target_filename, target_version = max(valid_matches, key=lambda match: version.parse(match[1]))

	url = f"{src_url}{target_filename}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
