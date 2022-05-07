#!/usr/bin/env python3

import json
import re

from bs4 import BeautifulSoup
from packaging.version import Version

'''
Get the official latest stable 1Password Linux release from the 1Password Linux homepage: https://releases.1password.com/linux/
The 1Password releases are structured on their releases pages from least stable (beta) to most stable
For each 1Password Linux release there is a dedicated sub page for that release

To reliable and robustly get the latest stable 1Password Linux release version it is a two step nested BeautifulSoup parsing exercise:
	1. Find all stable releases subpage's unique hrefs and extract the latest version
	2. Find and parse that release's JSON-LD context data from a unique script tag and extract the version from that data

Example of a 1Password Linux stable release sub page href attribute: /linux/8.5/
From that href we can extract the major version of the 1Password release

This is an example of using one BeautifulSoup parsed page to then parse another one by dynamically assembling a URL from data searched from the first page
The secondary 1Password Linux major release subpage URL example: https://releases.1password.com/linux/8.5/
Example of a 1Password Linux stable release JSON-LD context data embedded in a script tag from its major release subpage:
{'@context': 'https://schema.org', '@type': 'SoftwareApplication', 'name': '1Password for Linux', 'downloadUrl': 'https://support.1password.com/getting-started-linux/', 'applicationCategory': 'Productivity', 'applicationSubCategory': 'Password Manager', 'featureList': 'Password keeper, password generator, family and business sharing, auditing, reporting, compliance', 'operatingSystem': 'Linux', 'releaseNotes': 'https://releases.1password.com/linux/8.5/', 'screenshot': 'https://releases.1password.com/linux/8.5/hero.png', 'softwareVersion': '8.5.0'}

JSON-LD is simply HTML embedded data (https://en.wikipedia.org/wiki/JSON-LD) and we can directly deserialize it in Python
Once deserialized, then grab the direct software version of 1Password Linux. This JSON-LD should be updated when patched versions are released
The other side benefit of JSON-LD: some of its metadata can be used as autogen ebuild template pkginfo key values and then as Jinja variables
'''
async def get_releases(hub, **pkginfo):
	html = await hub.pkgtools.fetch.get_page("https://releases.1password.com/linux/")
	soup = BeautifulSoup(html, features="html.parser").find_all(href=re.compile("/linux/\d+\.\d+/$"))
	major_release = soup[0]["href"].lstrip("/").split("/")[1]
	html2 = await hub.pkgtools.fetch.get_page("https://releases.1password.com/linux/" + major_release + "/")
	soup2 = BeautifulSoup(html2, features="html.parser").find_all(type="application/ld+json")
	if len(soup2) >= 2:
		return json.loads(soup2[-1].contents[0])
	else:
		return None

async def generate(hub, **pkginfo):
	# Commenting this BeautifulSoup function out while we test 1Password upstream version file as a replacement
	#onepassword_release = await get_releases(hub, **pkginfo)
	#if onepassword_release is None:
	#	raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of 1Password")
	#version = onepassword_release["softwareVersion"]
	#
	# For completed details on this change see: https://bugs.funtoo.org/browse/FL-9796
	#
	# For the version of 1password Linux 1Password publishes an ASCII text file that contains the latest version, which allows us to deterministically derive the latest upstream package version.
	# See below for the URL format and the exact statement from 1Password Support Team
	# "We also publish two files that contain the version of our latest release, and they can be accessed at https://downloads.1password.com/linux/tar/stable/x86_64/LATEST and https://downloads.1password.com/linux/tar/beta/x86_64/LATEST respectively."
	upstream_version = await hub.pkgtools.fetch.get_page("https://downloads.1password.com/linux/tar/stable/x86_64/LATEST")
	if upstream_version is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable upstream version of 1Password Linux")
	version = Version(upstream_version)
	final_name = f"{pkginfo['name']}-{version.base_version}.tar.gz"
	# Upstream Stable URL Format: https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz
	# Upstream Beta URL Format: https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz
	url_homepage = f"https://releases.1password.com/linux/{str(version.major)}.{str(version.minor)}/"
	url = f"https://downloads.1password.com/linux/tar/stable/x86_64/1password-{version.base_version}.x64.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(final_name=final_name, url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version.base_version,
		homepage=url_homepage,
		keywords="-* amd64",
		artifacts=[src_artifact]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
