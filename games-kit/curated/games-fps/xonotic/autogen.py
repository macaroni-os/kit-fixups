#!/usr/bin/env python3

from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import re


async def generate(hub, **pkginfo):
	autobuild_url = "https://beta.xonotic.org/autobuild"
	src_pattern = re.compile("^\\.\\/(Xonotic-(\\d+)\.zip)$")

	autobuild_soup = BeautifulSoup(
		await hub.pkgtools.fetch.get_page(autobuild_url, refresh_interval=timedelta(days=30)), "lxml"
	)

	link_matches = (
		src_pattern.match(link.get("href")) for link in autobuild_soup.find_all("a")
	)
	valid_matches = (match.groups() for match in link_matches if match)

	target_filename, target_version = max(
		valid_matches,
		key=lambda match: datetime.strptime(match[1], "%Y%m%d"),
	)
	src_url = f"{autobuild_url}/{target_filename}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
	)
	ebuild.push()

