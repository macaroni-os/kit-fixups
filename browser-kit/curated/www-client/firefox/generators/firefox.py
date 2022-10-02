#!/usr/bin/python3

GLOBAL_DEFAULTS = {}

# https://bugs.funtoo.org/browse/FL-10519
# The dynamic fetching of Firefox language artifacts is the same methodoloy
# from the firefox-bin autogen. The get_lang_artifacts function is ripped
# from: kit-fixups/browser-kit/curated/www-client/firefox-bin/autogen.py

from bs4 import BeautifulSoup
base_url = "https://archive.mozilla.org"

async def get_lang_artifacts(hub, version, url_path, channel):
	uri_path = url_path

	if "nightly" not in channel:
	        uri_path = f"{url_path}/{version}"

	lang_url = f"{base_url}/pub/{uri_path}/linux-x86_64/xpi/"
	lang_page = await hub.pkgtools.fetch.get_page(lang_url)
	soup = BeautifulSoup(lang_page, "html.parser").find_all("a")

	# The xpi files are named differently for the nightlies (e.g. firefox-100.0a1.ach.langpack.xpi)
	# so the filename needs to be split differently to figure out the lang
	index = { 'default': 0, 'nightly': -3 }
	# Create an array of tuples for each lang: ('arch', href)
	langs = [(xpi.contents[0].split('.')[index.get(channel) or index['default']], xpi.get('href')) for xpi in soup if xpi.get('href').endswith('.xpi')]

	# Create an array of tuples each containing a lang's artifact: ('lang': artifact)
	artifacts = [(
		                lang[0],
		                hub.pkgtools.ebuild.Artifact(url=f"{base_url}{lang[1]}", final_name=f"firefox-{version}-{lang[0]}.xpi")
	        ) for lang in langs
	]
	return artifacts

async def generate(hub, **pkginfo):
	release_artifact = hub.pkgtools.ebuild.Artifact(
		url=f"{base_url}/pub/firefox/releases/{pkginfo['version']}/source/firefox-{pkginfo['version']}.source.tar.xz"
	)
	artifact = [
		("artifact", release_artifact)
	]
	patchset_artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://dev.gentoo.org/~{pkginfo['patchset_gentoo_dev']}/mozilla/patchsets/{pkginfo['patchset_tarball']}"
	)
	artifact_patchset = [
		("artifact_patchset", patchset_artifact)
	]
	lang_artifacts = await get_lang_artifacts(hub, pkginfo['version'], "firefox/releases", "stable")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=dict(artifact + artifact_patchset + lang_artifacts),
		lang_codes=dict(lang_artifacts).keys(),
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
