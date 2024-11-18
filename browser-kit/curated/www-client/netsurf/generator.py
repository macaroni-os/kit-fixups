#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

def generate_artifact(soup, download_url, tar):
	return (version, hub.pkgtools.ebuild.Artifact(url=download_url + latest_release))


async def generate(hub, **pkginfo):
	name = pkginfo.get("name")
	url = f"http://download.netsurf-browser.org/{pkginfo['url_suffix']}/"
	regex = r'(\d+(?:\.\d+)+)'

	# Download list of files
	html = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html, "html.parser").find_all("a", href=True)

	pkg = pkginfo.get('tar_name') or name

	pkginfo['version'], url_end = max([
		(generic.parse(re.findall(regex, a.contents[0])[0]), a.contents[0]) for a in soup if pkg in a.contents[0]
	])
	# workaround for metatools not doing the revisions properly on a version number like '3.10'
	# see https://bugs.funtoo.org/browse/FL-9547
	revision = None
	revision_info = pkginfo.get('revision')
	if isinstance(revision_info, dict):
		for vers, rev in revision_info.items():
			vers = generic.parse(vers)
			if vers != pkginfo['version']:
				continue
			pkginfo['revision'] = rev
			break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url+url_end)],
	)
	ebuild.push()



# vim: ts=4 sw=4 noet
