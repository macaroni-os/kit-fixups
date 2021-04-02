#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_url = f"https://pwmt.org/projects/zathura-pdf-mupdf/download/"
	html_data = await hub.pkgtools.fetch.get_page(html_url)
	soup = BeautifulSoup(html_data, "html.parser")
	best_artifact = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(".tar.xz"):
			best_artifact = href
			version = best_artifact.split(".tar")[0].split("-")[-1]
			break
	url = html_url + best_artifact

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
