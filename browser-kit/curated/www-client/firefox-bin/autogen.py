#!/usr/bin/env python3

import json
import re


async def get_lang_artifacts(hub, version, url_path):
	lang_page = await hub.pkgtools.fetch.get_page(
		f"https://archive.mozilla.org/pub/{url_path}/{version}/linux-x86_64/xpi/"
	)
	lang_codes = []
	artifacts = []
	for lang_path in re.findall(f'/pub/{url_path}/{version}/linux-x86_64/xpi/[^"]*\.xpi', lang_page):
		lang_code = lang_path.split("/")[-1].split(".")[0]
		lang_codes.append(lang_code)
		artifacts.append(
			hub.pkgtools.ebuild.Artifact(
				url="https://archive.mozilla.org" + lang_path, final_name=f"firefox-{version}-{lang_code}.xpi"
			)
		)
	return dict(artifacts=artifacts, lang_codes=lang_codes)


def get_artifact(hub, name, version, url_path, arch):
	if arch == "amd64":
		moz_arch = "x86_64"
	elif arch == "x86":
		moz_arch = "i686"
	# Construct the upstream url and transform the upstream version to a portage friendly version if necessary
	if name == "firefox-bin":
		url = f"https://archive.mozilla.org/pub/{url_path}/{version}/linux-{moz_arch}/en-US/firefox-{version}.tar.bz2"
		final_name = f"{name}_{moz_arch}-{version}.tar.bz2"
	elif name.split('-')[1] == "beta":
		url = f"https://archive.mozilla.org/pub/{url_path}/{version}/linux-{moz_arch}/en-US/firefox-{version}.tar.bz2"
		final_name = f"{name}_{moz_arch}-{version.replace('b','_beta')}.tar.bz2"
	elif name.split('-')[1] == "dev":
		url = f"https://archive.mozilla.org/pub/{url_path}/{version}/linux-{moz_arch}/en-US/firefox-{version}.tar.bz2"
		final_name = f"{name}_{moz_arch}-{version.replace('b','_beta')}.tar.bz2"
	elif name.split('-')[1] == "nightly":
		url = f"https://archive.mozilla.org/pub/{url_path}/firefox-{version}.en-US.linux-{moz_arch}.tar.bz2"
		final_name = f"{name}_{moz_arch}-{version.replace('a','_alpha')}.tar.bz2"
	else:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't match a Firefox release channel name when getting artifacts. Package name used for matching criteria: {name}")
	return hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://product-details.mozilla.org/1.0/firefox_versions.json")
	json_dict = json.loads(json_data)
	# Stable Latest Firefox Release Channel
	version = json_dict["LATEST_FIREFOX_VERSION"]
	url_path_dir_stable = "firefox/releases"
	lang_data = await get_lang_artifacts(hub, version, url_path_dir_stable)
	# Beta Firefox Release Channel
	version_beta = json_dict["LATEST_FIREFOX_RELEASED_DEVEL_VERSION"]
	version_beta_final = version_beta.replace('b','_beta')
	url_path_dir_beta = "firefox/releases"
	lang_data_beta = await get_lang_artifacts(hub, version_beta, url_path_dir_beta)
	# Developer's Edition Aurora Firefox Release Channel
	version_dev = json_dict["FIREFOX_DEVEDITION"]
	version_dev_final = version_dev.replace('b','_beta')
	url_path_dir_dev = "devedition/releases"
	lang_data_dev = await get_lang_artifacts(hub, version_dev, url_path_dir_dev)
	# Nightly Firefox Release Channel
	version_nightly = json_dict["FIREFOX_NIGHTLY"]
	version_nightly_final = version_nightly.replace('a','_alpha')
	url_path_dir_nightly = "firefox/nightly/latest-mozilla-central"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		install_dir="/opt/firefox",
		url_path_dir=url_path_dir_stable,
		version=version,
		lang_codes=" ".join(sorted(lang_data["lang_codes"])),
		artifacts=[get_artifact(hub, pkginfo['name'], version, url_path_dir_stable, "amd64"), get_artifact(hub, pkginfo['name'], version, url_path_dir_stable, "x86"), *lang_data["artifacts"]],
	)
	ebuild.push()
	ebuild_beta= hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		template=ebuild.template,
		cat=pkginfo["cat"],
		name="firefox-beta-bin",
		install_dir="/opt/firefox-beta",
		url_path_dir=url_path_dir_beta,
		version=version_beta_final,
		artifacts=[get_artifact(hub, "firefox-beta-bin", version_beta, url_path_dir_beta, "amd64"), get_artifact(hub, "firefox-beta-bin", version_beta, url_path_dir_beta, "x86"), *lang_data_beta["artifacts"]],
	)
	ebuild_beta.push()
	ebuild_dev = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		template=ebuild.template,
		cat=pkginfo["cat"],
		name="firefox-dev-bin",
		install_dir="/opt/firefox-dev",
		url_path_dir=url_path_dir_dev,
		version=version_dev_final,
		artifacts=[get_artifact(hub, "firefox-dev-bin", version_dev, url_path_dir_dev, "amd64"), get_artifact(hub, "firefox-dev-bin", version_dev, url_path_dir_dev, "x86"), *lang_data_dev["artifacts"]],
	)
	ebuild_dev.push()
	ebuild_nightly = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		template=ebuild.template,
		cat=pkginfo["cat"],
		name="firefox-nightly-bin",
		install_dir="/opt/firefox-nightly",
		url_path_dir=url_path_dir_nightly,
		version=version_nightly_final,
		artifacts=[get_artifact(hub, "firefox-nightly-bin", version_nightly, url_path_dir_nightly, "amd64"), get_artifact(hub, "firefox-nightly-bin", version_nightly, url_path_dir_nightly, "x86")],
	)
	ebuild_nightly.push()


# vim: ts=4 sw=4 noet
