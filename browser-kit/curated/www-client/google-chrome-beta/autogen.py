#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):

	RELEASE_CHANNEL = PACKAGE_APPENDIX = pkginfo["name"].split("-")[-1]
	json_data = await hub.pkgtools.fetch.get_page("https://omahaproxy.appspot.com/json")
	json_dict = json.loads(json_data)
	linux_os = list(filter(lambda x: x["os"] == "linux", json_dict))[0]
	channel = list(filter(lambda x: x["channel"] == RELEASE_CHANNEL, linux_os["versions"]))[0]
	version = channel["version"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-{PACKAGE_APPENDIX}/google-chrome-{PACKAGE_APPENDIX}_{version}-1_amd64.deb"
			)
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
