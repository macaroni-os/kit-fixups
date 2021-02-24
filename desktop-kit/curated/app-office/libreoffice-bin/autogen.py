#!/usr/bin/env python3

from bs4 import BeautifulSoup

def get_lang_artifacts(hub, lang_url, lang_soup, lang_type):
	langs = " "
	artifacts = []
	for link in lang_soup.find_all("a"):
		href = link.get("href")
		if lang_type in href and href.endswith("tar.gz"):
			abbrv = href.split(".tar")[0].split("_")[-1]
			if "en-US" in abbrv:
				abbrv = "en:en-US"
			elif "pa-IN" in abbrv:
				abbrv = "pa:pa-IN"
			elif "sa-IN" in abbrv:
				abbrv = "sa:sa-IN"
			langs = langs + abbrv + " "
			artifacts.append(
				hub.pkgtools.ebuild.Artifact(url=lang_url+href)
			)
	return dict(langs=langs,artifacts=artifacts)


async def generate(hub, **pkginfo):
	html_url = f"https://www.libreoffice.org/download/download/"
	html_data = await hub.pkgtools.fetch.get_page(html_url)
	soup = BeautifulSoup(html_data, "html.parser")
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(".xz?idx=1"):
			fullversion = href.split(".tar")[0].split("-")[1]
	version = ".".join(fullversion.split(".")[:-1])
	dl_url = f"https://download.documentfoundation.org/libreoffice/stable/{version}/rpm/x86_64/"
	dl_data = await hub.pkgtools.fetch.get_page(dl_url)
	dl_soup = BeautifulSoup(dl_data, "html.parser")
	langpack = get_lang_artifacts(hub, dl_url, dl_soup, "langpack")
	helppack = get_lang_artifacts(hub, dl_url, dl_soup, "helppack")
	url = dl_url + f"LibreOffice_{version}_Linux_x86-64_rpm.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url)]

	ebuild_bin = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=fullversion, artifacts=artifacts)
	ebuild_bin.push()
	ebuild_l10n = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild_bin.template_path,
		cat=pkginfo["cat"],
		name="libreoffice-l10n",
		version=fullversion,
		languages=langpack["langs"],
		languages_help=helppack["langs"],
		artifacts=[
			*langpack["artifacts"],
			*helppack["artifacts"],
		],
	)
	ebuild_l10n.push()


# vim: ts=4 sw=4 noet
