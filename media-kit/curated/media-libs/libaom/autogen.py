#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic

# We are going to parse the release tags directly from the website since they don't 
# appear to have a usable rest api.
# The tags we are interested in all look like this:
# <a href="/aom/+/refs/tags/v3.1.2">v3.1.2</a>
async def get_version(hub):
	page = await hub.pkgtools.fetch.get_page("https://aomedia.googlesource.com/aom/+refs")
	tag_list = []
	for a in BeautifulSoup(page, features='html.parser').find_all('a', href=True):
		if a['href'].startswith("/aom/+/refs/tags/"):
			tag_text = a.get_text()
			# Drop any tags that start with 'research' or contain 'rc'. We only want normal versions.
			if "research" in tag_text or "rc" in tag_text:
				continue
			else:
				tag_list.append(tag_text)
				
	# Sort the list and return the first one which should be the latest version
	return None if not tag_list else  sorted(tag_list, key=lambda x: generic.parse(x)).pop()
	
	


async def generate(hub, **pkginfo):
	version = await get_version(hub)
	if version is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {pkginfor['name']}")
	version = version.lstrip("v")
	slot = version.split(".")[0]
	url = f"https://storage.googleapis.com/aom-releases/{pkginfo['name']}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		slot=slot,
		artifacts=[src_artifact]
	)
	ebuild.push()
	
