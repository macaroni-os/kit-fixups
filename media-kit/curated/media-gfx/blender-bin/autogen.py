#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	src_url = "https://download.blender.org/release/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	main_link_list = reversed(list(filter(lambda a: re.match("Blender[0-9.]+/", a.get("href")), soup.find_all("a"))))

	# Blender directory listings appear to show versions in "version order", due to the way the versions are normalized. Therefore, we
	# are interested in the *last* match, which is the latest version. However, we had an instance where a directory was created with
	# no contents yet (FL-12148) so we have to check that there is at least one valid version in the subdirectory. Thus, we start with
	# the latest version subdirectory and fall back to next-most-recent, etc.

	found = False
	for main_link in main_link_list:
		xz_data = await hub.pkgtools.fetch.get_page(src_url + main_link.get("href"))
		for xz_link in reversed(list(filter(lambda a: re.search("blender-[0-9.]+-linux-x64\.tar\.xz", a.get("href")), BeautifulSoup(xz_data, "html.parser").find_all("a")))):
			best_artifact = xz_link.get("href")
			version = best_artifact.split(".tar")[0].split("-")[1]
			url = src_url + main_link.get("href") + best_artifact
			found = True
			break
		if found:
			break

	if not found:
		raise ValueError("A suitable version of Blender could not be found.")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
