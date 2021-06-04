#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	compression = pkginfo["compression"]
	src_url = f"https://ftp.gnu.org/gnu/{app}/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	best_artifact = None
	if "version" not in pkginfo or pkginfo["version"] == "latest":
		for link in soup.find_all("a"):
			href = link.get("href")
			if href.endswith(f".tar.{compression}") and not "latest" in href:
				best_artifact = href
				version = best_artifact.split(".tar")[0].split("-")[1]
	else:
		version = pkginfo["version"]
	pkginfo["version"] = version
	url = src_url + f"{app}-{version}.tar.{compression}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
