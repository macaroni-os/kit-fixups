#!/usr/bin/env python3

import asyncio


async def generate_for(hub, url_path, release_name, binary_name, masked, **pkginfo):
	url = await hub.pkgtools.fetch.get_url_from_redirect(f"https://discord.com/api/download{url_path}?platform=linux&format=deb")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		release_name=release_name,
		binary_name=binary_name,
		keywords="" if masked else "~amd64",
		version=url.split("/")[-1].lstrip(f"{release_name}-").rstrip(".deb"),
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


async def generate(hub, **pkginfo):
	await generate_for(hub, "", "discord", "Discord", False, **pkginfo)
	await generate_for(hub, "/canary", "discord-canary", "DiscordCanary", True, **pkginfo)


# vim: ts=4 sw=4 noet
