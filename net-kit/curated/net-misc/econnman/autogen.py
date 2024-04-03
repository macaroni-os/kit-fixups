#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic


# We are going to parse the versions from their available downloads since they don't 
# appear to have a usable rest api.
# The tags we are interested in all look like this:
# <a href="pkgname-1.23.3.tar.xz">pkgname-1.23.3.tar.xz</a>
async def get_version(hub, url, pkgname):
	page = await hub.pkgtools.fetch.get_page(url)
	version_list = []
	# Look for the td class 'indexcolname' and grab the child href to avoid grabbing the icons 
	# as well since they also contain an href link
	for td in BeautifulSoup(page, features='html.parser').find_all('td', class_="indexcolname"):
		href_str = td.find("a", href=True)['href']
		
		# Filter out alpha and beta releases along with the sha256 links
		if "alpha" in href_str or "beta" in href_str or "sha256" in href_str:
			continue
		# Filter out anything that doesn't start with pkgname
		if not href_str.startswith(pkgname):
			continue
			
		# Strip everything but the version number from the string
		ver_num = href_str.lstrip(f"{pkgname}-").rstrip(".tar.xz")
		version_list.append(ver_num)

	# Sort the list and return the first one which should be the latest version
	return None if not version_list else  sorted(version_list, key=lambda x: generic.parse(x)).pop()


async def generate(hub, **pkginfo):
	repo_dir = "apps"
	url_prefix = f"https://download.enlightenment.org/rel/{repo_dir}/{pkginfo['name']}"
	ver_num = await get_version(hub, url_prefix, pkginfo['name'])
	if ver_num is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {pkginfo['name']}")
	url = f"{url_prefix}/{pkginfo['name']}-{ver_num}.tar.xz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=ver_num,
		artifacts=[src_artifact]
	)
	ebuild.push()
