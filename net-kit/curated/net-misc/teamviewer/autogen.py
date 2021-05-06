#!/usr/bin/env python3

import asyncio

async def generate(hub, **pkginfo):

	url = await hub.pkgtools.fetch.get_url_from_redirect("https://download.teamviewer.com/download/linux/teamviewer_amd64.tar.xz")
	version = url.split("/")[-1].lstrip("teamviewer_").rstrip("amd64.tar.xz").replace("_", "")

	artifacts = [
		hub.pkgtools.ebuild.Artifact(url=url, final_name=f"teamviewer_{version}_amd64.tar.xz"),
		hub.pkgtools.ebuild.Artifact(url=url.replace("amd64", "i386"), final_name=f"teamviewer_{version}_i386.tar.xz"),
	]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, artifacts=artifacts)

	ebuild.push()
