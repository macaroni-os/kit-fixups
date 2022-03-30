#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	googles = {
		'google-chrome': {
			'channel': 'stable',
			'appendix': 'stable',
		},
		'google-chrome-beta': {
			'channel': 'beta',
			'appendix': 'beta',
		},
		'google-chrome-unstable': {
			'channel': 'dev',
			'appendix': 'unstable',
			'rdepend': ['dev-libs/wayland']
		},
	}

	json_data = await hub.pkgtools.fetch.get_page("https://omahaproxy.appspot.com/json")
	json_dict = json.loads(json_data)
	basename = "google-chrome"
	url = f"https://dl.google.com/linux/chrome/deb/pool/main/g/"

	for chrome in googles:
		pkginfo['name'] = chrome
		browser = googles[chrome]
		name = f"{basename}-{browser['appendix']}"
		channel = browser['channel']

		linux_os = list(filter(lambda x: x["os"] == "linux", json_dict))[0]
		release = list(filter(lambda x: x["channel"] == channel, linux_os["versions"]))[0]

		version = release["version"]
		appendix = browser["appendix"]

		artifact = hub.pkgtools.ebuild.Artifact(url=f"{url}{name}/{name}_{version}-1_amd64.deb")

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			channel=channel,
			rdepend=browser.get('rdepend') or [],
			artifacts=[artifact],
			template=f"{basename}.tmpl"
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
