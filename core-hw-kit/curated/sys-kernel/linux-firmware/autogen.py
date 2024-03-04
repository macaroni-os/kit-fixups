#!/usr/bin/env python3

from bs4 import BeautifulSoup

revisions={
	"20211027": "2",
	"20220209": "1"
}

masked_versions={
	"20240220" : "FL-12114 (amdgpu regression)"
}

async def generate(hub, **pkginfo):
	url = f"https://git.kernel.org"
	html_data = await hub.pkgtools.fetch.get_page(
		url + f"/pub/scm/linux/kernel/git/firmware/linux-firmware.git/refs/tags/"
	)
	soup = BeautifulSoup(html_data, "html.parser")
	
	# generate the three most recent versions:
	best_archives = []

	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(".tar.gz"):
			best_archives.append(href)
		if len(best_archives) >= 3:
			break

	for best_archive in best_archives:
		version = best_archive.split(".tar")[0].split("-")[-1]
		masked = version in masked_versions
		mask_reason = masked_versions[version] if masked else ""
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url + f"{best_archive}")],
			revision=revisions,
			masked=masked,
			mask_reason=mask_reason
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
