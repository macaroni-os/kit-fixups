#!/usr/bin/env python3

import asyncio


async def generate(hub, **pkginfo):

	url = await hub.pkgtools.fetch.get_url_from_redirect("https://discordapp.com/api/download?platform=linux&format=deb")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=url.split("/")[-1].lstrip("discord-").rstrip(".deb"),
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
