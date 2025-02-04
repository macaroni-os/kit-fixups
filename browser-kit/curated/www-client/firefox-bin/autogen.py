#!/usr/bin/env python3

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


def get_moz_url(version, url_path, arch, channel):
	# The tarballs for nightlies are named differently
	if "nightly" in channel:
		return f"{base_url}/pub/{url_path}/firefox-{version}.en-US.linux-{arch}.tar.xz"

	return f"{base_url}/pub/{url_path}/{version}/linux-{arch}/en-US/firefox-{version}.tar.xz"


def get_artifacts(hub, name, version, url_path, channel):
	# Lookup mozilla arch strings using the Funtoo arch strings
	moz = {
		"amd64": "x86_64",
		"x86": "i686",
	}

	archive_type = "tar.xz"

	# Construct the upstream url and transform the upstream version to a portage friendly version
	return [(
		arch,
		hub.pkgtools.ebuild.Artifact(
			url=get_moz_url(version, url_path, moz[arch], channel),
			final_name=f"{name}_{moz[arch]}-{version.replace('a','_alpha').replace('b','_beta')}.{archive_type}")
	) for arch in moz]


async def generate(hub, **pkginfo):
	info_url = "https://product-details.mozilla.org/1.0/firefox_versions.json"
	json_data = await hub.pkgtools.fetch.get_page(info_url, is_json=True)

	pkgname = "firefox"

	# metadata about each of the different release channels
	firefoxes = {
		'stable': {
			'version': "LATEST_FIREFOX_VERSION",
			'url_path': "firefox/releases",
		},
		'beta': {
			'version': "LATEST_FIREFOX_RELEASED_DEVEL_VERSION",
			'url_path': "firefox/releases",
		},
		'dev': {
			'version': "FIREFOX_DEVEDITION",
			'url_path': "devedition/releases",
		},
#		'nightly': {
#			'version': "FIREFOX_NIGHTLY",
#			'url_path': "firefox/nightly/latest-mozilla-central",
#			'l10n_path': "firefox/nightly/latest-mozilla-central-l10n",
#		},
	}

	# Loop through each release channel and push out an ebuild
	for release in firefoxes:
		firefox = firefoxes[release]
		version = json_data[firefox['version']]
		url_path = firefox['url_path']
		lang_path = firefox.get('l10n_path') or url_path

		suffix = ''
		if "stable" not in release: suffix = f"-{release}"
		pkginfo["name"] = f"{pkgname}{suffix}-bin"

		lang_artifacts = await get_lang_artifacts(hub, version, lang_path, release)
		arch_artifacts = get_artifacts(hub, pkginfo['name'], version, url_path, release)

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			base_url=f"{base_url}/pub/mozilla",
			url_path_dir=url_path,
			version=version.replace('a','_alpha').replace('b','_beta'),
			channel=release,
			lang_codes=dict(lang_artifacts).keys(),
			arches=dict(arch_artifacts).keys(),
			template="firefox-bin.tmpl",
			artifacts=dict(arch_artifacts + lang_artifacts)
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
