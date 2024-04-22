#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import os
import re

base_url = "https://ftp.gnu.org/gnu/"
base_regex = r'(\d+(?:\.\d+)+)'
mask_above = Version("8.2")

async def generate(hub, **pkginfo):
	name = pkginfo['name']
	regex = name + '-' + base_regex
	stable_regex = base_regex + '.tar.gz'
	package_url = base_url + name

	tarballs = [t for t in await fetch_soup(hub, package_url, '.tar.') if  not '-doc' in t.contents[0]]
	versions = [(Version(re.findall(regex, a.contents[0])[0]), a.get('href')) for a in tarballs if re.findall(regex, a.contents[0])]
	latest = max([v for v in versions if not v[0].is_prerelease])
	#latest = max([v for v in versions if v[0] < mask_above and not v[0].is_prerelease])

	tarball_artifact = [hub.pkgtools.ebuild.Artifact(url=f"{package_url}/{latest[1]}")]

	# get patches for versions that don't have a micro (e.g. 8.1 or 8.2, but not 8.1.2 or 8.2.1)
	patch_level, patch_artifacts = await fetch_patches(hub, package_url, name, latest[0])
	version = f"{latest[0].public}"
	if patch_level:
		version += f"_p{patch_level}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		soname=latest[0].major,
		base_version=latest[0].public,
		version=version,
		artifacts=tarball_artifact + patch_artifacts,
		patches=[p.final_name for p in patch_artifacts],
	)
	ebuild.push()

async def fetch_soup(hub, url, name):
	html = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

	return [a for a in soup if name in a.contents[0] and not a.contents[0].endswith('.sig')]


async def fetch_patches(hub, package_url, name, version):
	url = f"{package_url}/{name}-{version}-patches/"
	try:
		name = f"{name}{version.public.replace('.','')}"

		patches = await fetch_soup(hub, url, name)
		patch_artifacts = [hub.pkgtools.ebuild.Artifact(url=url + p.get('href')) for p in patches]
		plevel = max([Version(p.contents[0].split('-')[1]) for p in patches]).public
	except:
		return 0, []

	return plevel, patch_artifacts

# vim: ts=4 sw=4 noet
