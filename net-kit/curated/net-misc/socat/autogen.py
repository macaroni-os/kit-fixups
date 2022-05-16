#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	src_url = "http://www.dest-unreach.org/socat/download/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	best_artifact = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(f".tar.bz2"):
			ver = href.split(".tar")[0].split("-")[-1]
			if ver.upper().isupper():
				continue
			best_artifact = href
			version = ver
	url = src_url + best_artifact

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
