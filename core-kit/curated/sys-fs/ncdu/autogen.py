#!/usr/bin/env python3

from packaging import version
from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	download_url = "https://dev.yorhel.nl/download"
	src_pattern = re.compile(f"^({pkginfo.get('name')}-([\\d.]+)\\.tar\\.gz)$")

	download_soup = BeautifulSoup(
		await hub.pkgtools.http.get_page(download_url), "lxml"
	)

	link_matches = (
		src_pattern.match(link.get("href")) for link in download_soup.find_all("a")
	)
	valid_matches = (match.groups() for match in link_matches if match)

	parsed_versions = (
		(filename, version.parse(ver)) for (filename, ver) in valid_matches if ver
	)

	# FIXME: ncdu v2.x.x uses Zig, we don't have it in our tree yet
	max_version = version.parse("2.0.0")
	c_versions = (
		(filename, ver) for (filename, ver) in parsed_versions if ver < max_version
	)

	target_filename, target_version = max(
		c_versions,
		key=lambda match: match[1],
	)
	src_url = f"{download_url}/{target_filename}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
	)
	ebuild.push()

