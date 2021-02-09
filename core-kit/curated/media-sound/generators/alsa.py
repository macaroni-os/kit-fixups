#!/usr/bin/python3

GLOBAL_DEFAULTS = {}
ALSA_BASE_URL = "https://www.alsa-project.org/files/pub"


async def generate(hub, **pkginfo):
	name = pkginfo["name"]
	version = pkginfo["version"]
	if "subdir" in pkginfo:
		subdir = pkginfo["subdir"]
	elif name.startswith("alsa-"):
		subdir = name[5:]
	else:
		subdir = name
	url = ALSA_BASE_URL + "/" + subdir + "/" + f"{name}-{version}.tar.bz2"
	art = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[art])
	ebuild.push()


# vim: ts=4 sw=4 noet
