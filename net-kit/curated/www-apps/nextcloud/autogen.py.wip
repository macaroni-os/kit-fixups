#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	changelog_url = "https://nextcloud.com/changelog/"
	changelog_data = await hub.pkgtools.fetch.get_page(changelog_url)
	changelog_soup = BeautifulSoup(changelog_data, "html.parser")
	latest_tags = [x for x in changelog_soup.find_all("a", attrs={"id": True}) if x["id"].startswith("latest")]
	latest_urls = [x.find_next("a", href=True) for x in latest_tags]
	url_pattern = re.compile(f"nextcloud-(.*)\.tar\.bz2")
	for latest_url in latest_urls:
		source_url = latest_url["href"]
		source_version, = url_pattern.search(source_url).groups()
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=source_version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=source_url)]
		)
		ebuild.push()
