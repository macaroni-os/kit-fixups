#!/usr/bin/python3

GLOBAL_DEFAULTS = {}


async def generate(hub, **pkginfo):
	if "src_uri" in pkginfo:
		new_src_uri = []
		if isinstance(pkginfo["src_uri"], list):
			artifacts = []
			for url in pkginfo["src_uri"]:
				new_src_uri.append(hub.Artifact(url=url))
		elif isinstance(pkginfo["src_uri"], str):
			new_src_uri.append(hub.Artifact(url=pkginfo["src_uri"]))
		# Allow our default expander to be used:
		pkginfo["artifacts"] = new_src_uri
		del pkginfo["src_uri"]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()


# vim: ts=4 sw=4 noet
