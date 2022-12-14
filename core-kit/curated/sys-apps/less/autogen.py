#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	base_url = "https://www.greenwoodsoftware.com/less"
	dl_data = await hub.pkgtools.fetch.get_page(f"{base_url}/download.html")
	dl_soup = BeautifulSoup(dl_data, "lxml")
	for a in dl_soup.find_all("a", href=True):
		href = a["href"]
		if not href.endswith(".tar.gz"):
			continue
		if not href.startswith("less-"):
			continue
		fn = href
		version = href[:-7].split("-")[1]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		# This fixes an issue where aiohttp transparently decompresses gzip:
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"{base_url}/less-{version}.tar.gz", extra_http_headers={"Accept-Encoding" : "identity"})]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
