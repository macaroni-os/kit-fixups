#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	repo_data = await hub.pkgtools.fetch.get_page("https://www.linuxsampler.org/libgig/")
	repo_soup = BeautifulSoup(repo_data, 'html.parser')

	for link in repo_soup.find_all('a', href=True):
		if link["href"].endswith(".tar.bz2"):
			url = link["href"]
			version = link["href"].split('-')[-1].rstrip('.tar.bz2')
			break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,version=version,artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
