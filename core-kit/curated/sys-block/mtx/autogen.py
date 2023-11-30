#!/usr/bin/env python3

from bs4 import BeautifulSoup
import packaging
import re
from urllib.parse import urljoin


async def generate(hub, **pkginfo):
	project_name="mtx"
	project_name = pkginfo.get("name")

	sourceforge_url = f"https://sourceforge.net/projects/{project_name}/files/mtx-stable"
 
	sourceforge_soup = BeautifulSoup(
			await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
			)

	files_list = sourceforge_soup.find(id="files_list")
	base_url = None
	for link in files_list.tbody.find_all("a", href=True):
		if "/files/" not in link["href"]:
			continue
		base_url = link["href"]
		break
	project_path = urljoin(sourceforge_url, base_url).rstrip("/")
	version = pkginfo["version"] = project_path.split("/")[-1]
  # https://sourceforge.net/projects/mtx/files/mtx-stable/1.3.12/mtx-1.3.12.tar.gz/download 
	pkginfo["artifacts"] = [ hub.Artifact(url=f"{project_path}/mtx-{version}.tar.gz") ]
	hub.pkgtools.ebuild.BreezyBuild(**pkginfo).push()