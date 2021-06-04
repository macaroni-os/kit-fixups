#!/usr/bin/env python3

import asyncio


async def generate(hub, **pkginfo):

	url = await hub.pkgtools.fetch.get_url_from_redirect(
		"https://download.teamviewer.com/download/linux/teamviewer_amd64.tar.xz"
	)
	version = url.split("_")[-2]

	artifacts = {
		"amd64": hub.pkgtools.ebuild.Artifact(url=url),
		"x86": hub.pkgtools.ebuild.Artifact(url=url.replace("amd64", "i386")),
	}

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, artifacts=artifacts)
	ebuild.push()
