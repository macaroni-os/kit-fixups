#!/usr/bin/env python3

import json

lightning_version = "68.0b6"

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

async def generate(hub):

	json_data = await hub.pkgtools.fetch.get_page("https://product-details.mozilla.org/1.0/thunderbird_versions.json")
	json_dict = json.loads(json_data)
	version = json_dict["LATEST_THUNDERBIRD_VERSION"]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		hub,
		name="thunderbird-bin",
		cat="mail-client",
		version=version,
		artifacts=[
			get_artifact(hub, version, "amd64"),
			get_artifact(hub, version, "x86"),
			hub.pkgtools.ebuild.Artifact(url=f"https://dev.gentoo.org/~juippis/distfiles/lightning-{lightning_version}.tar.xz")
		],
		lightning_version=lightning_version
	)
	ebuild.push()

# vim: ts=4 sw=4 noet