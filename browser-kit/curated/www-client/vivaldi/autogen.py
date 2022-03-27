#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
from collections import defaultdict
from datetime import timedelta
import re

arches = {
	'amd64': 'amd64',
	'armhf': 'arm',
	'arm64': 'arm64',
}

def generate_ebuild(base_url, key, debs, **pkginfo):
	candidates = defaultdict(lambda: dict())
	for deb in debs:
		found = re.match(f"vivaldi-{key}_([0-9.-]+)_(.*)\.deb", deb)
		if not found:
			continue
		else:
			groups = found.groups()
			candidates[groups[0]][groups[1]] = deb
	if not len(candidates):
		return
	latest = sorted(candidates.keys(), key=lambda x: Version(x.replace("-", ".")), reverse=True)[0]
	candidate = candidates[latest]
	artifacts = {}
	for arch, url in candidate.items():
		artifacts[arch] = hub.pkgtools.ebuild.Artifact(url=base_url+url)
	version = latest.replace("-", "_p")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts,
		template='vivaldi.tmpl',
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	base_url = "https://repo.vivaldi.com/{release}/deb/pool/main/"
	for release in [ 'stable', 'snapshot' ]:
		real_url = base_url.format(release=release)
		html = await hub.pkgtools.fetch.get_page(real_url, refresh_interval=timedelta(days=3))
		soup = BeautifulSoup(html, features="html.parser").find_all("a")
		debs = [a.contents[0] for a in soup if a.contents[0].endswith('deb')]
		if release != "stable":
			pkginfo['name'] = f"vivaldi-{release}"
		generate_ebuild(real_url, release, debs, **pkginfo)

# vim: ts=4 sw=4 noet
