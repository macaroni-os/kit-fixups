#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging import version


async def generate(hub, **pkginfo):
	sourceforge_url = f"https://sourceforge.net/projects/enlightenment/files/imlib2-src"
	sourceforge_soup = BeautifulSoup(
		await hub.pkgtools.http.get_page(sourceforge_url), "lxml"
	)

	files_list = sourceforge_soup.find(id="files_list")
	versions = (
		version_row.get("title") for version_row in files_list.tbody.find_all("tr")
	)

	target_version = max(versions, key=lambda ver: version.parse(ver))

	src_url = f"https://downloads.sourceforge.net/enlightenment/{pkginfo.get('name')}-{target_version}.tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
	)
	ebuild.push()

