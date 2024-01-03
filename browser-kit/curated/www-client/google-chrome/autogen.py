#!/usr/bin/env python3


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

	basename = "google-chrome"
	url = "https://dl.google.com/linux/chrome/deb/pool/main/g/"

	for chrome in googles:
		pkginfo['name'] = chrome
		browser = googles[chrome]
		channel = browser['channel']

		chromium_url = f"https://chromiumdash.appspot.com/fetch_releases?channel={channel}&platform=Linux&num=1"
		data = await hub.pkgtools.fetch.get_page(chromium_url, is_json=True)

		if data and len(data) > 0:
			version = data[0]["version"]
			name = f"{basename}-{browser['appendix']}"
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
		else:
			raise hub.pkgtools.ebuild.BreezyError(f"Failed to fetch version data for {channel} channel")

# vim: ts=4 sw=4 noet
