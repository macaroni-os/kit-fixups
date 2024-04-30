#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	src_url = f"https://statmath.wu.ac.at/software/RngStreams/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(f".tar.gz"):
			urlsuffix = href
			version = href.split(".tar")[0].split("-")[1]
			break
	url = src_url + urlsuffix

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
