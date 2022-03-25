#!/usr/bin/env python3

from packaging.version import Version
from bs4 import BeautifulSoup
import re

async def generate(hub, **pkginfo):
	name = pkginfo.get("name")
	url = f"https://www.x.org/releases/individual/app/"
	html = await hub.pkgtools.fetch.get_page(url, is_json=False)
	soup = BeautifulSoup(html, features="html.parser").find_all('a', href=True)

	releases= [pkg.contents[0] for pkg in soup if (name in pkg.contents[0] and pkg.contents[0].endswith('tar.xz'))]
	latest_release = releases[-1]

	version = latest_release.rsplit("-")[-1].split(".tar")[0]

	print(version)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url + latest_release)],
		version=version
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
