#!/usr/bin/env python3

import json
import re

from bs4 import BeautifulSoup

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
	onepassword_release = await get_releases(hub, **pkginfo)
	if onepassword_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of 1Password")
	version = onepassword_release["softwareVersion"]
	final_name = f"{pkginfo['name']}-{version}.tar.gz"
	url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(final_name=final_name, url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		description=onepassword_release["featureList"],
		homepage=onepassword_release["releaseNotes"],
		keywords="-* amd64",
		artifacts=[src_artifact]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
