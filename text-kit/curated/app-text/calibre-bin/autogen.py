#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	major_url = f"http://download.calibre-ebook.com/"
	major_data = await hub.pkgtools.fetch.get_page(major_url)
	major_soup = BeautifulSoup(major_data, "html.parser")
	
	ver_ref = "5.html"
	ver_data = await hub.pkgtools.fetch.get_page(major_url + ver_ref)
	ver_soup = BeautifulSoup(ver_data, "html.parser")
	version = ver_soup.find("a").get_text()
	
	src_url = major_url + version + "/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	src_soup = BeautifulSoup(src_data, "html.parser")
	for link in src_soup.find_all("a"):
		href = link.get("href")
		if href is not None and href.endswith("i686.txz"):
			url = src_url + href
			break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts={
			"x86": hub.pkgtools.ebuild.Artifact(url=url),
			"amd64": hub.pkgtools.ebuild.Artifact(url=url.replace("i686","x86_64")),
		}
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
