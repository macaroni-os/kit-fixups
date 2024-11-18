#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re


async def generate(hub, **pkginfo):
	changelog_url = "https://www.gnu.org/savannah-checkouts/gnu/emacs/emacs.html"
	changelog_data = await hub.pkgtools.fetch.get_page(changelog_url)
	changelog_soup = BeautifulSoup(changelog_data, "lxml")
	releases_div = changelog_soup.find("div", class_="releases")
	version_pattern = re.compile("Emacs ([\d\.]+)")
	version_headers = releases_div.find_all("h2")
	version_matches = (version_pattern.match(x.text.strip()) for x in version_headers)
	(target_version,) = next(x.groups() for x in version_matches if x)
	url = f"http://ftp.gnu.org/gnu/emacs/emacs-{target_version}.tar.xz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[src_artifact],
		major_version=generic.parse(target_version).major,
	)
	ebuild.push()
