#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	url = "https://cran.r-project.org/src/base/R-4/"
	html_data = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html_data, "html.parser")
	best_archive = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.startswith("R") and href.endswith(".tar.gz"):
			best_archive = href
	version = best_archive.split(".tar")[0].split("-")[1]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url + f"{best_archive}")]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
