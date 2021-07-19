#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	url = f"https://git.kernel.org"
	html_data = await hub.pkgtools.fetch.get_page(
		url + f"/pub/scm/libs/klibc/klibc.git/refs/tags/"
	)
	soup = BeautifulSoup(html_data, "html.parser")
	best_archive = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(".tar.gz"):
			best_archive = href
			break
	version = best_archive.split(".tar")[0].split("-")[-1]
	headers_data = await hub.pkgtools.fetch.get_page(
		"https://www.kernel.org/releases.json", is_json=True
	)
	headers_version = headers_data["latest_stable"]["version"].split(".")[:2]
	headers_url = f"https://cdn.kernel.org/pub/linux/kernel/v{headers_version[0]}.x/linux-" \
		+ ".".join(headers_version) + ".tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		headers_version=headers_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url + f"{best_archive}",),
			hub.pkgtools.ebuild.Artifact(headers_url),
		]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
