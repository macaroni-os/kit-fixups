#!/usr/bin/env python3

import re
from bs4 import BeautifulSoup


def extract_urls(tag, pattern):
	return list(filter(None, [pattern.match(t.get("href")) for t in tag.find_all("a", href=True)]))


def find_source(hub, name, source_list, url_pattern):
	source_tags = extract_urls(source_list, url_pattern)
	if not source_tags:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release for {name}!")

	return source_tags[0].groups()


def find_translations(hub, name, language_list, url_pattern):
	translation_matches = extract_urls(language_list, url_pattern)
	if not translation_matches:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find translations for {name}!")

	translation_urls = [m.group(1) for m in translation_matches]
	translation_names = " ".join([m.group(2) for m in translation_matches])

	translations_list = "\n\t\t".join(translation_urls)

	translation_artifacts = [hub.pkgtools.ebuild.Artifact(url=url) for url in translation_urls]

	return dict(names=translation_names, list=translations_list, artifacts=translation_artifacts)


async def generate(hub, **pkginfo):
	name = pkginfo["name"]

	download_page_data = await hub.pkgtools.fetch.get_page("http://www.xpdfreader.com/download.html")

	download_page_soup = BeautifulSoup(download_page_data, "html.parser")
	for ul in download_page_soup.find_all("ul"):
		sibling_text = ul.findPrevious().text.lower()
		if "source code" in sibling_text:
			source_list = ul
		elif "language" in sibling_text:
			language_list = ul

	url_pattern = re.compile(r"(https:\/\/dl\.xpdfreader\.com\/xpdf-(.*)\.tar\.gz)")

	source_url, version = find_source(hub, name, source_list, url_pattern)
	translation_data = find_translations(hub, name, language_list, url_pattern)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		translations=translation_data["list"],
		translation_names=translation_data["names"],
		artifacts=[hub.pkgtools.ebuild.Artifact(url=source_url), *translation_data["artifacts"]],
	)
	ebuild.push()
