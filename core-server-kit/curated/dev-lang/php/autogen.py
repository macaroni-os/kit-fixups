#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	slots = [
		('7.2', ['php-freetype-2.9.1.patch', 'php-7.2.13-intl-use-icu-namespace.patch']),
		('7.3', ['php-freetype-2.9.1.patch']),
		('7.4', ['php-iodbc-header-location.patch']),
	]
	php_url = 'https://www.php.net/downloads.php'
	php_data = await hub.pkgtools.fetch.get_page(php_url)
	dists_url = 'https://www.php.net/distributions/php-{}.tar.bz2'
	for slot, patch_list in slots:
		patches = "(\n"
		for patch in patch_list:
			patches += "\t\"${FILESDIR}/" + patch + "\"\n"
		patches += ")"
		version = re.findall(f"php-({slot}\\.\\d+).tar", php_data)[0]
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			slot=slot,
			patches=patches,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=dists_url.format(version))
			],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
