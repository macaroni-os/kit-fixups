#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html = await hub.pkgtools.fetch.get_page("https://rawtherapee.com")
	url = None
	file = None
	for a in BeautifulSoup(html, features="html.parser").find_all('a', href=True):
		href = a['href']
		file = href.split('/')[-1]
		if file.endswith(".tar.xz") and file.startswith("rawtherapee"):
			url = href
			break
	if url is None:
		raise hub.pkgtools.ebuild.BreezyError("Couldn't locate rawtherapee download link.")
	version = file[:-7].split("-")[1]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
