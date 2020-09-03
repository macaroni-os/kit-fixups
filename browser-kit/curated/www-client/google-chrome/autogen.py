#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://omahaproxy.appspot.com/json")
	json_dict = json.loads(json_data)
	linux_os = list(filter(lambda x: x["os"] == "linux", json_dict))[0]
	stable = list(filter(lambda x: x["channel"] == "stable", linux_os["versions"]))[0]
	version = stable["version"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_{version}-1_amd64.deb"
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
