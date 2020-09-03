#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	hplip_plugin_url = "https://developers.hp.com/hp-linux-imaging-and-printing/release_notes"
	dist_url = "https://developers.hp.com/sites/default/files/hplip-{}-plugin.run"
	hplip_plugin_data = await hub.pkgtools.fetch.get_page(hplip_plugin_url)
	version = re.findall(r"HPLIP (\d+\.\d+\.\d+)", hplip_plugin_data)[0]
	hplip_version = re.findall(r"(\d+\.\d+).\d+", version)[0] + ".0"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		hplip_version=hplip_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=dist_url.format(version))],
	)
	ebuild.push()
