#!/usr/bin/env python3

import json
import re


async def get_lang_artifacts(hub, version):
	lang_page = await hub.pkgtools.fetch.get_page(
		f"https://archive.mozilla.org/pub/firefox/releases/{version}/linux-x86_64/xpi/"
	)
	lang_codes = []
	artifacts = []
	for lang_path in re.findall(f'/pub/firefox/releases/{version}/linux-x86_64/xpi/[^"]*\.xpi', lang_page):
		lang_code = lang_path.split("/")[-1].split(".")[0]
		lang_codes.append(lang_code)
		artifacts.append(
			hub.pkgtools.ebuild.Artifact(
				url="https://archive.mozilla.org" + lang_path, final_name=f"firefox-{version}-{lang_code}.xpi"
			)
		)
	return dict(artifacts=artifacts, lang_codes=lang_codes)


def get_artifact(hub, name, version, arch):
	if arch == "amd64":
		moz_arch = "x86_64"
	elif arch == "x86":
		moz_arch = "i686"
	url = f"https://archive.mozilla.org/pub/firefox/releases/{version}/linux-{moz_arch}/en-US/firefox-{version}.tar.bz2"
	final_name = f"{name}_{moz_arch}-{version.replace('b','_beta')}.tar.bz2"
	return hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://product-details.mozilla.org/1.0/firefox_versions.json")
	json_dict = json.loads(json_data)
	version = json_dict["LATEST_FIREFOX_VERSION"]
	version_dev = json_dict["LATEST_FIREFOX_RELEASED_DEVEL_VERSION"]
	version_dev_final = version_dev.replace('b','_beta')
	lang_data = await get_lang_artifacts(hub, version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		install_dir="/opt/firefox",
		version=version,
		lang_codes=" ".join(sorted(lang_data["lang_codes"])),
		artifacts=[get_artifact(hub, pkginfo['name'], version, "amd64"), get_artifact(hub, pkginfo['name'], version, "x86"), *lang_data["artifacts"]],
	)
	ebuild.push()
	ebuild_dev = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		template=ebuild.template,
		cat=pkginfo["cat"],
		name="firefox-dev-bin",
		install_dir="/opt/firefox-dev",
		version=version_dev_final,
		artifacts=[get_artifact(hub, "firefox-dev-bin", version_dev, "amd64"), get_artifact(hub, "firefox-dev-bin", version_dev, "x86"), *lang_data["artifacts"]],
	)
	ebuild_dev.push()


# vim: ts=4 sw=4 noet
