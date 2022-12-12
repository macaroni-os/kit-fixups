#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	col_url = f"https://dev.gentoo.org/~sam/distfiles/sys-firmware/intel-microcode/"
	html_data = await hub.pkgtools.fetch.get_page(col_url)
	soup = BeautifulSoup(html_data, "html.parser")
	best_archive = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(".tar.xz"):
			best_archive = href
	col_version = best_archive.split(".tar")[0].split("-")[-1]
	github_user = "intel"
	github_repo = "Intel-Linux-Processor-Microcode-Data-Files"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		intel_version = release["tag_name"].split("-")[-1]
		intel_url = release["tarball_url"]
		break
	version = f"{intel_version}_p{col_version}"
	final_name = f"microcode-{intel_version}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=col_url + f"{best_archive}"),
			hub.pkgtools.ebuild.Artifact(url=intel_url, final_name=final_name),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
