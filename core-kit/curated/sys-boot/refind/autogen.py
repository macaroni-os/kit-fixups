#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re

async def get_from_green_download_button(soup):
	"""
	This function attempts to grab the latest imlib2 from the green download button. I added this because it happened to 
	work-around an issue we saw where there was an empty imlib2 folder. However, we have recently seen the green download
	button point to the WRONG component of enlightenment (e16 instead of imlib2!) so I guess this requires englightenment
	people to use sourceforge properly!
	"""
	# Target the green download button -- it contains the official latest version! :)
	latest = soup.find(class_="download")
	# This grabs the tarball name in group 0 and the version in group 1:
	subpath_grp = re.match(".*(refind-src-(.*)\.tar\.[gx]z)", latest.get("title"))
	if subpath_grp is None:
		return {}
	final_name = subpath_grp.groups()[0]
	version = subpath_grp.groups()[1]
	url = f"https://downloads.sourceforge.net/enlightenment/{final_name}"
	return {
		"artifacts" : [hub.pkgtools.ebuild.Artifact(url=url)],
		"version" : version
	}

async def get_from_folder(soup):
	"""
	This function tries each imlib2 folder listed on the download page, in order (they appear to always be in descending order).
	It will continue looking in each successive folder until a legitimate imlib2 version is found. This *should* be robust and
	should always find a version.
	"""
	files_list = soup.find(id="files_list")
	artifact = None
	for version_row in files_list.tbody.find_all("tr"):
		version = version_row.get("title")
		try:
			artifact = hub.pkgtools.ebuild.Artifact(url=f"https://downloads.sourceforge.net/project/refind/{version}/refind-src-{version}.tar.gz")
			await artifact.fetch()
		except hub.pkgtools.fetch.FetchError:
			artifact = None
			continue
		break
	if artifact is None:
		return {}
	return {
		"artifacts" : [artifact],
		"version" : version
	}


async def generate(hub, **pkginfo):
	sourceforge_url = f"https://sourceforge.net/projects/refind/files"
	soup = BeautifulSoup(
		await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
	)
	pkginfo.update(await get_from_green_download_button(soup))
	if "artifact" not in pkginfo:
		pkginfo.update(await get_from_folder(soup))
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
