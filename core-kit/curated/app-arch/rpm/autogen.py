#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

regex = r'(\d+(?:\.\d+)+)'
target_version = Version('4.18.1')
target_major = Version('4.18')

async def generate(hub, **pkginfo):
	base_url = "http://ftp.rpm.org/releases/"
	html = await hub.pkgtools.fetch.get_page(base_url)
	soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)
	for a in soup:
		if not a.get('href').startswith(pkginfo['name']):
			continue
		found_version = Version(re.findall(regex, a.get('href'))[0])
		if str(found_version) == str(target_major):
			download_url = base_url + a.get('href')
			break

	html = await hub.pkgtools.fetch.get_page(download_url)
	soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)
	url = None
	for a in soup:
		if '.tar.' not in a.get('href'):
			continue
		found_version = Version(re.findall(regex, a.get('href'))[0])
		if str(found_version) == str(target_version):
			pkginfo['version'] = str(found_version)
			url = f"{download_url}{a.get('href')}"
			break
	if url is None:
		raise ValueError("Couldn't find suitable version.")
	artifact = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[artifact],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
