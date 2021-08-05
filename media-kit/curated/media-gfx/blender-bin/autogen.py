#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	src_url = "https://download.blender.org/release/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	slot = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.replace("Blender","").upper().isupper():
			continue
		slot = href
	src_data = await hub.pkgtools.fetch.get_page(src_url + slot)
	soup = BeautifulSoup(src_data, "html.parser")
	best_artifact = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(f".tar.xz"):
			best_artifact = href
			version = best_artifact.split(".tar")[0].split("-")[1]
	url = src_url + slot + best_artifact

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
