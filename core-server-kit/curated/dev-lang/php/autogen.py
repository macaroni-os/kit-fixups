#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	slots = [
		('7.2', 'latest', ['php-freetype-2.9.1.patch', 'php-7.2.13-intl-use-icu-namespace.patch'], None),
		('7.3', 'latest', ['php-freetype-2.9.1.patch'], None),
		('7.4', 'latest', ['php-iodbc-header-location.patch', 'apache.patch'], None),
		('8.0', '8.0.0_beta1', ['php-iodbc-header-location.patch', 'apache.patch'], 'https://downloads.php.net/~carusogabriel/php-8.0.0beta1.tar.gz')
	]
	php_url = 'https://www.php.net/downloads.php'
	php_data = await hub.pkgtools.fetch.get_page(php_url)
	for slot, v_spec, patch_list, dists_url in slots:
		patches = "(\n"
		for patch in patch_list:
			patches += "\t\"${FILESDIR}/" + patch + "\"\n"
		patches += ")"
		if v_spec == 'latest':
			version = re.findall(f"php-({slot}\\.\\d+).tar", php_data)[0]
		else:
			version = v_spec
		if dists_url is None:
			dists_url = f'https://www.php.net/distributions/php-{version}.tar.bz2'
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			template=f'php-{slot}.tmpl',
			version=version,
			slot=slot,
			patches=patches,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=dists_url)
			],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
