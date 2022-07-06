#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	src_url = f"https://libgeos.org/usage/download/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(f".tar.bz2"):
			url = href
			version = href.split(".tar")[0].split("-")[1]
			break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
