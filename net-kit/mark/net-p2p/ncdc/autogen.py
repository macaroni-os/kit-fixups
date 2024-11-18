#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

regex = r'(\d+(?:[\.-]\d+)+)'

async def generate(hub, **pkginfo):
	name = pkginfo['name']
	base_url="https://dev.yorhel.nl"
	html = await hub.pkgtools.fetch.get_page(base_url + "/download")
	soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

	releases = [a for a in soup if name in a.contents[0] and not 'linux' in a.contents[0] and a.contents[0].endswith('gz')]
	latest = max([(
			generic.parse(re.findall(regex, a.contents[0])[0]),
			a.get('href'))
		for a in releases if re.findall(regex, a.contents[0])
	])
	artifact = hub.pkgtools.ebuild.Artifact(url=base_url + latest[1])

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest[0],
		artifacts=[artifact]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
