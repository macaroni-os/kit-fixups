#!/usr/bin/env python3

import json
import re

async def generate(hub, **pkginfo):
	slots = [
		'7.2',
		'7.3',
		'7.4'
	]
	php_url = "https://www.php.net/downloads.php"
	php_data = await hub.pkgtools.fetch.get_page(php_url)
	dists_url = "https://www.php.net/distributions/php-{}.tar.bz2"
	for slot in slots:
		version = re.findall("{}\..?".format(slot), php_data)[0]
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			slot=slot,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=dists_url.format(version))
			],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
