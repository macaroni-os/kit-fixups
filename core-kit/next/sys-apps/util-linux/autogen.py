#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re

async def generate(hub, **pkginfo):
	python_compat="python3+"
	tags_url = f"https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/refs/tags/"
	html_data = await hub.pkgtools.fetch.get_page(tags_url)
	soup = BeautifulSoup(html_data, "html.parser")
	best_archive = None
	for link in soup.find_all("a"):
		href = link.get("href")
		fn = href.split("/")[-1]
		if re.match('util-linux-[0-9.]+\.tar', fn):
			best_archive = href
			break
	version = best_archive.split(".tar")[0].split("-")[-1]
	shortver = ".".join(version.split(".")[0:2])
	url = f"https://www.kernel.org/pub/linux/utils/util-linux/v{shortver}/util-linux-{version}.tar.xz"
	artifact = hub.pkgtools.ebuild.Artifact(url=url)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, python_compat=python_compat, artifacts=[artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
