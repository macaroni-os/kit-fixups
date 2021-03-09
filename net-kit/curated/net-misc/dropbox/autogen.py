#!/usr/bin/env python3

from packaging import version
from bs4 import BeautifulSoup

def get_release(releases_data):
	matches = [x for x in releases_data if x.startswith('nautilus-dropbox')]
	releases = sorted((x for x in matches if x), key=lambda x: version.parse(x[0]))
	return releases.pop() if releases else None

async def generate(hub, **pkginfo):
	urlamd64 = await hub.pkgtools.fetch.get_url_from_redirect('https://www.dropbox.com/download?plat=lnx.x86_64')
	urlx86 = await hub.pkgtools.fetch.get_url_from_redirect('https://www.dropbox.com/download?plat=lnx.x86')
	urlnaut = 'https://linux.dropbox.com/packages/'
	repo_data = await hub.pkgtools.fetch.get_page(urlnaut)
	repo_soup = BeautifulSoup(repo_data, 'html.parser')
	links = []
	for link in repo_soup.find_all('a', href=True):
		links.append(link['href'])
	latest_release = get_release(links)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release")
	naut_filename=latest_release
	github_repo='dropbox-python-setup'
	github_user='funtoo'
	github_tag='1.1'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=urlamd64.split('-')[-1].rstrip('.tar.gz'),
		python_compat='python3+',
		github_repo=github_repo,
		github_user=github_user,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=urlamd64),
			hub.pkgtools.ebuild.Artifact(url=urlx86),
			hub.pkgtools.ebuild.Artifact(url=(urlnaut + naut_filename)),
			hub.pkgtools.ebuild.Artifact(
				url=f'https://www.github.com/{github_user}/{github_repo}/tarball/{github_tag}',
				final_name=f'{github_repo}-{github_tag}.tar.gz',
			),
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
