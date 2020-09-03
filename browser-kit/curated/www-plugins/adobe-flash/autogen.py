#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://get.adobe.com/flashplayer/about/")
	match = re.search(
		'<table class="data-bordered max">.*Linux.*Firefox - NPAPI</td>\s*<td>([0-9.]+)</td>', json_data, re.DOTALL
	)
	if match is None:
		version = "32.0.0.363"
	else:
		version = match.group(1)
	base_url = "https://fpdownload.adobe.com/pub/flashplayer/pdc"
	artifacts = [
		hub.pkgtools.ebuild.Artifact(
			url=f"{base_url}/{version}/flash_player_npapi_linux.x86_64.tar.gz",
			final_name=f'{pkginfo["name"]}-{version}-npapi.x86_64.tar.gz',
		),
		hub.pkgtools.ebuild.Artifact(
			url=f"{base_url}/{version}/flash_player_ppapi_linux.x86_64.tar.gz",
			final_name=f'{pkginfo["name"]}-{version}-ppapi.x86_64.tar.gz',
		),
	]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, artifacts=artifacts)
	ebuild.push()


# vim: ts=4 sw=4 noet
