#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	tracker_url = "https://packages.debian.org/source/stable/dvhtool"
	base_src_url = "http://deb.debian.org/debian/pool/main/d/dvhtool"
	tracker_data = await hub.pkgtools.fetch.get_page(tracker_url)
	tracker_soup = BeautifulSoup(tracker_data, "lxml")
	source_pattern = re.compile(".*dvhtool_(.*)-(\d+).*")
	source_matches = [source_pattern.match(x["href"]) for x in tracker_soup.find_all("a", href=True)]
	source_files = [x.groups() for x in source_matches if x]
	version_major, version_minor = source_files.pop()
	if version_major == '1.0.1':
		target_version = f"{version_major}-r3"
	else:
		target_version = f"{version_major}"
	orig_src_uri = f"{base_src_url}/dvhtool_{version_major}.orig.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=orig_src_uri),
		]
	)
	ebuild.push()
