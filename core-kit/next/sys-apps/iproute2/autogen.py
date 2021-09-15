#!/usr/bin/env python3

from bs4 import BeautifulSoup

def split_cmp(s1, s2):
	if s1 is None:
		return s2
	if s2 is None:
		return s1
	for pos in [0, 1, 2]:
		if s1[pos] > s2[pos]:
			return s1
		elif s2[pos] > s1[pos]:
			return s2
	return s1

async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	src_url = f"https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	version = None
	best_split = None
	for link in reversed(soup.find_all("a")):
		# The links are not ordered. We will analyze each version component and find the latest version:
		href = link.get("href")
		if not href.endswith(".tar.xz"):
			continue
		if not href.startswith("iproute2-"):
			continue
		cur_version = href.split("-")[1][:-7]
		split = list(map(int, cur_version.split(".")))
		best_split = split_cmp(best_split, split)
		if best_split == split:
			version = cur_version
	url = f"{src_url}iproute2-{version}.tar.xz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
