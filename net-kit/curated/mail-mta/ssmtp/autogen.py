#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	tracker_url = "https://packages.debian.org/source/stable/ssmtp"
	base_src_url = "http://deb.debian.org/debian/pool/main/s/ssmtp"
	tracker_data = await hub.pkgtools.fetch.get_page(tracker_url)
	tracker_soup = BeautifulSoup(tracker_data, "lxml")
	source_pattern = re.compile(".*ssmtp_(.*)-(\d+).*")
	source_matches = [source_pattern.match(x["href"]) for x in tracker_soup.find_all("a", href=True)]
	source_files = [x.groups() for x in source_matches if x]
	version_major, version_minor = source_files.pop()
	if version_major == '2.64':
		target_version = f"{version_major}-r4"
	else:
		target_version = f"{version_major}"
	orig_src_uri = f"{base_src_url}/ssmtp_{version_major}.orig.tar.bz2"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=orig_src_uri),
		]
	)
	ebuild.push()

