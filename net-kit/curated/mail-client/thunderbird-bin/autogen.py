#!/usr/bin/env python3

import json
import re

lightning_version = "68.0b6"

async def get_lang_artifacts(hub, version):
	lang_page = await hub.pkgtools.fetch.get_page(f"https://archive.mozilla.org/pub/thunderbird/releases/{version}/linux-x86_64/xpi/")
	lang_codes = []
	artifacts = []
	for lang_path in re.findall(f'/pub/thunderbird/releases/{version}/linux-x86_64/xpi/[^"]*\.xpi', lang_page):
		lang_code = lang_path.split('/')[-1].split('.')[0]
		lang_codes.append(lang_code)
		artifacts.append(hub.pkgtools.ebuild.Artifact(url='https://archive.mozilla.org' + lang_path, final_name=f'thunderbird-{version}-{lang_code}.xpi'))
	return dict(
		artifacts=artifacts,
		lang_codes=lang_codes
	)

def get_artifact(hub, version, arch):
	if arch == "amd64":
		moz_arch = "x86_64"
	elif arch == "x86":
		moz_arch = "i686"
	url = f"https://archive.mozilla.org/pub/thunderbird/releases/{version}/linux-{moz_arch}/en-US/thunderbird-{version}.tar.bz2"
	final_name = f'thunderbird-bin_{moz_arch}-{version}.tar.bz2'
	return hub.pkgtools.ebuild.Artifact(
		url=url,
		final_name=final_name
	)

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://product-details.mozilla.org/1.0/thunderbird_versions.json")
	json_dict = json.loads(json_data)
	version = json_dict["LATEST_THUNDERBIRD_VERSION"]
	lang_data = await get_lang_artifacts(hub, version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		lang_codes=' '.join(sorted(lang_data['lang_codes'])),
		artifacts=[
			get_artifact(hub, version, "amd64"),
			get_artifact(hub, version, "x86"),
			hub.pkgtools.ebuild.Artifact(url=f"https://dev.gentoo.org/~juippis/distfiles/lightning-{lightning_version}.tar.xz"),
			*lang_data['artifacts']
		],
		lightning_version=lightning_version
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
