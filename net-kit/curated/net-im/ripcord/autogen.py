#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	homepage_data = await hub.pkgtools.fetch.get_page("https://cancel.fm/ripcord")
	homepage_soup = BeautifulSoup(homepage_data, "lxml")
	source_pattern = re.compile("(https:\/\/cancel.fm\/dl\/((\w+)-([\d\.]+)-x86_64.AppImage))")
	source_matches = [source_pattern.match(x["href"]) for x in homepage_soup.find_all("a", href=True)]
	source_urls = [x.groups() for x in source_matches if x]
	source_url, source_filename, source_binary, source_version = source_urls.pop()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=source_version,
		appimage_name=source_filename,
		binary_name=source_binary,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=source_url)]
	)
	ebuild.push()
