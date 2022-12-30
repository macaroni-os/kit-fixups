#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	python_compat = "python3_10+"
	src_url = "https://download.blender.org/source/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	best_artifact = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(f".tar.xz") and "with" not in href:
			best_artifact = href
			version = best_artifact.split(".tar")[0].split("-")[1]
	url = src_url + best_artifact

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
