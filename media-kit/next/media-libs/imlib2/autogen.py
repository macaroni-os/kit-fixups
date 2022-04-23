#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	sourceforge_url = f"https://sourceforge.net/projects/enlightenment/files/imlib2-src"
	sourceforge_soup = BeautifulSoup(
		await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
	)
	# Target the green download button -- it contains the official latest version! :)
	latest = sourceforge_soup.find(class_="download")
	# This grabs the tarball name in group 0 and the version in group 1:
	subpath_grp = re.match(".*(imlib2-(.*)\.tar\.[gx]z)", latest.get("title"))
	final_name = subpath_grp.groups()[0]
	version = subpath_grp.groups()[1]
	url = f"https://downloads.sourceforge.net/enlightenment/{final_name}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
