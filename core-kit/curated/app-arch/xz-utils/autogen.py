#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	base_url = "https://tukaani.org/xz/"
	dl_data = await hub.pkgtools.fetch.get_page(base_url)
	dl_soup = BeautifulSoup(dl_data, "lxml")
	for a in dl_soup.find_all("a", href=True):
		href = a["href"]
		if not href.endswith(".tar.gz"):
			continue
		if not href.startswith("xz-"):
			continue
		fn = href
		version = href[:-7].split("-")[1]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"{base_url}/xz-{version}.tar.gz")]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet

