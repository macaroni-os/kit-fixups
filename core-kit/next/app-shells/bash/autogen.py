#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import os
import re

base_url = "https://ftp.gnu.org/gnu/"
base_regex = r'(\d+(?:\.\d+)+)'
# This toggles whether the template tries to use an external readline library. We need to make
# sure we have the required version of readline available in the tree before enabling:
external_readline = False

async def generate(hub, **pkginfo):
	name = pkginfo['name']
	regex = name + '-' + base_regex
	stable_regex = base_regex + '.tar.gz'
	package_url = base_url + name

	html = await hub.pkgtools.fetch.get_page(package_url)
	soup = BeautifulSoup(html, 'html.parser').find_all('a', href=True)

	tarballs = [a.get('href') for a in soup if '.tar.' in a.contents[0] and re.findall(regex, a.contents[0]) and not a.contents[0].endswith('.sig')]
	versions = [(Version(a.split(f"{name}-")[1].split('.tar.')[0]), a) for a in tarballs]
	stable_version = max([v for v in versions if re.findall(stable_regex, v[1])])
	newest_version = max(versions)
	
	readline = None
	versions = [stable_version]
	if stable_version != newest_version:
		versions.append(newest_version)
	for version in versions:
		artifact = hub.pkgtools.ebuild.Artifact(url=f"{package_url}/{version[1]}")
		pkginfo['artifacts'] = [artifact]
		conversion = convert_version(version, name)
		if external_readline:
			readline = await get_readline_version(artifact, name, conversion)
		await generate_ebuild(hub, version=conversion, unstable=version[0].is_prerelease, readline=readline, external_readline=external_readline, **pkginfo)


def convert_version(newest, name):
	if newest[0].is_prerelease:
		return newest[1].split(f"{name}-")[1].split('.tar.')[0]
	return newest[0].public


async def get_readline_version(artifact, name, version):
	rlheader = os.path.join(artifact.extract_path, f"{name}-{version}", "lib/readline/readline.h")

	await artifact.fetch()
	artifact.extract()
	with open(rlheader, "r") as rlh:
		lines = rlh.readlines()
		for line in lines:
			if "RL_VERSION_MAJOR" in line:
				rl_major = line.split()[-1]
			if "RL_VERSION_MINOR" in line:
				rl_minor = line.split()[-1]

	return Version(f"{rl_major}.{rl_minor}")


async def generate_ebuild(hub, version=0, unstable=False, readline=None, **pkginfo):
	vers = version
	if unstable:
		vers = version.replace('-', '_')

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		readline=readline,
		stable=not unstable,
		version=vers
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
