#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	url = f"https://www.iana.org/time-zones"
	html_data = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html_data, "html.parser")
	best_tzdata = None
	pattern = re.compile(".*tzdata(.*)\.tar\.gz")
	for link in soup.find_all("a"):
		href = link.get("href")
		if pattern.match(href):
			best_tzdata = href
			break
	version = pattern.match(best_tzdata).group(1)
	best_tzcode = re.sub(r"tzdata", "tzcode", best_tzdata)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=best_tzdata), hub.pkgtools.ebuild.Artifact(url=best_tzcode)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
