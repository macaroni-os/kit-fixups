#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	base_url = "http://www.ladspa.org/download"
	download_data = await hub.pkgtools.fetch.get_page(f"{base_url}/index.html")
	download_soup = BeautifulSoup(download_data, "lxml")
	source_pattern = re.compile(f"({base_url}/ladspa_sdk_(.*).tgz)")
	source_matches = [source_pattern.match(x["href"]) for x in download_soup.find_all("a", href=True)]
	source_files = [x.groups() for x in source_matches if x]
	source_url, source_version = source_files.pop()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=source_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=source_url)]
	)
	ebuild.push()
