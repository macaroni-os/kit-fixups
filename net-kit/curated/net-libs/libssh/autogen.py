#!/usr/bin/env python3

from bs4 import BeautifulSoup

def get_release(releases_data):
	releases = list(filter(lambda x: x["href"].endswith(".tar.xz") and "release" not in x["href"], releases_data))
	return None if not releases else sorted(releases, key=lambda x: x["href"]).pop()

async def generate(hub, **pkginfo):
	repo_data = await hub.pkgtools.fetch.get_page("https://git.libssh.org/projects/libssh.git/refs/tags")
	repo_soup = BeautifulSoup(repo_data, 'html.parser')

	release = get_release(repo_soup.find_all('a', href=True))
	url = "https://git.libssh.org" + release["href"]
	version = release["href"].split('-')[-1].rstrip('.tar.xz')

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,version=version,artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
