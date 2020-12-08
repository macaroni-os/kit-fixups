#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):
	wikidata = await hub.pkgtools.fetch.get_page("https://minecraft.gamepedia.com/api.php?action=query&titles=Template:Version&format=json&prop=revisions&rvprop=content&rvslots=*", is_json=True)
	page = list(wikidata['query']['pages'].values())[0]["revisions"][0]["slots"]["main"]["*"]
	# Mask the beta launcher -- unmask the other :)
	for key, keywords in [ ("launcher-lin", "amd64"), ("launcher-lin-beta", "") ]:
		found = re.search( key + "\s+=\s+([0-9.]+)", page)
		if found is None:
			logging.warning(f"Could not find minecraft-launcher key {key}, skipping ebuild generation.")
			continue
		version = found.group(1)
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			keywords=keywords,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(
					url=f"https://launcher.mojang.com/download/linux/x86_64/minecraft-launcher_{version}.tar.gz"
				)
			],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
