#!/usr/bin/env python3

# this autogen generates 3 packages: fldigi, flmsg and flrig - as they are under same umbrella

from bs4 import BeautifulSoup
from metatools.version import generic
import re

async def generate(hub, **pkginfo):

	project_name="fldigi"
	subprojects = ["fldigi", "flmsg", "flrig"]

	for subproject in subprojects:
		subproject_name = subproject
		pkginfo["name"] = subproject_name
		sourceforge_url = f"https://sourceforge.net/projects/{project_name}/files/{subproject_name}"
		sourceforge_soup = BeautifulSoup(
				await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
		)
		files_list = sourceforge_soup.find(id="files_list")
		files = [i.span.text for i in files_list.tbody.find_all("tr",{'class' : 'file'})]
		files = filter(lambda x: x.endswith(".tar.gz"), files) # filter upto source
		versions = { generic.parse(re.search(r"\d+\.\d+(\.\d+)?", file).group()): file for file in files }
		target_version = max(versions.keys())
		target_file = versions[target_version]
		src_url = f"https://downloads.sourceforge.net/{project_name}/{subproject_name}/{target_file}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
				**pkginfo,
				version=target_version,
				artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
				)
		ebuild.push()

# vim: ts=4 sw=4 noet
