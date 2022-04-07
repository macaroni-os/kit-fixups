#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import os
import re

base_url = "https://ftp.gnu.org/gnu/"
base_regex = r'(\d+(?:\.\d+)+)'

async def generate(hub, **pkginfo):
	name = pkginfo['name']
	regex = name + '-' + base_regex
	stable_regex = base_regex + '.tar.gz'
	package_url = base_url + name

	html = await hub.pkgtools.fetch.get_page(package_url)
	soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)


	tarballs = [a.get('href') for a in soup if '.tar.' in a.contents[0] and re.findall(regex, a.contents[0]) and not a.contents[0].endswith('.sig') and not '-doc' in a.contents[0]]
	versions = [(Version(a.split(f"{name}-")[1].split('.tar.')[0]), a) for a in tarballs]
	stable_version = max([v for v in versions if re.findall(stable_regex, v[1])])
	newest_version = max(versions)

	for version in [stable_version, newest_version]:
		artifact = hub.pkgtools.ebuild.Artifact(url=f"{package_url}/{version[1]}")
		pkginfo['artifacts'] = [artifact]
		conversion = convert_version(version, name)
		await generate_ebuild(hub, version=conversion, unstable=version[0].is_prerelease, soname=version[0].major, **pkginfo)



def convert_version(newest, name):
	if newest[0].is_prerelease:
		return newest[1].split(f"{name}-")[1].split('.tar.')[0]
	return newest[0].public



async def generate_ebuild(hub, version=0, unstable=False, soname=None, **pkginfo):
	vers = version
	if unstable:
		vers = version.replace('-', '_')

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		soname=soname,
		stable=not unstable,
		version=vers
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
