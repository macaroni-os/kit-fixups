#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re


async def generate(hub, **pkginfo):
	base_url = "https://www.zsh.org/pub"
	files_data = await hub.pkgtools.fetch.get_page(base_url)
	files_soup = BeautifulSoup(files_data, "lxml")
	name_pattern = re.compile(re.compile("^zsh-([0-9\.]+).tar.xz$"))
	file_matches = (name_pattern.match(x.get("href")) for x in files_soup.find_all("a", href=True))
	target_version = next(x.group(1) for x in file_matches if x)
	source_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/zsh-{target_version}.tar.xz")
	doc_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/zsh-{target_version}-doc.tar.xz")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=target_version, artifacts=[source_artifact, doc_artifact])
	ebuild.push()
