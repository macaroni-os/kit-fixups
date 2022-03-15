#!/usr/bin/env python3

from packaging import version
from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	download_url = "https://dev.yorhel.nl/download"
	src_pattern = re.compile(f"^({pkginfo.get('name')}-([\\d.]+)\\.tar\\.gz)$")

	download_soup = BeautifulSoup(
		await hub.pkgtools.fetch.get_page(download_url), "lxml"
	)

	link_matches = (
		src_pattern.match(link.get("href")) for link in download_soup.find_all("a")
	)
	valid_matches = (match.groups() for match in link_matches if match)

	parsed_versions = (
		(filename, version.parse(ver)) for (filename, ver) in valid_matches if ver
	)

	target_filename, target_version = max(
		parsed_versions,
		key=lambda match: match[1],
	)
	src_url = f"{download_url}/{target_filename}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
	)
	ebuild.push()

