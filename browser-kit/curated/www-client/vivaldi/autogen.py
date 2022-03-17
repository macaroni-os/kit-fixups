#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

arches = {
	'amd64': 'amd64',
	'armhf': 'arm',
	'arm64': 'arm64',
}

url = "https://repo.vivaldi.com/archive/deb/pool/main/"

def generate_ebuild(key, debs, **pkginfo):
	releases = [a for a in debs if key in a]
	latest = max([Version(a.split('_')[1]) for a in releases])
	version = f"{latest.base_version}_p{latest.post}"

	artifacts = dict([
		(arches[(a.split('_')[2].split('.')[0])], hub.pkgtools.ebuild.Artifact(url=url + a))
	for a in releases])

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts,
		template='vivaldi.tmpl',
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	html = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html, features="html.parser").find_all("a")

	debs = [a.contents[0] for a in soup if a.contents[0].endswith('deb')]
	generate_ebuild("stable", debs, **pkginfo)

	pkginfo['name'] = 'vivaldi-snapshot'
	generate_ebuild("snapshot", debs, **pkginfo)



# vim: ts=4 sw=4 noet
