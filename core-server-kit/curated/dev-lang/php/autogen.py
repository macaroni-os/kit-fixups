#!/usr/bin/env python3

import logging
import re

async def generate(hub, **pkginfo):
	slots = [
		("7.4", "latest", ["php-iodbc-header-location.patch", "apache.patch", "bug81656-gcc-11.patch"], None),
		("8.0", "latest", ["php-iodbc-header-location.patch", "php80-firebird-warnings.patch"], None),
		("8.1", "latest" , ["php-iodbc-header-location.patch"], None),
	]
	php_url = "https://www.php.net/releases/?json&version={slot}"
	for slot, v_spec, patch_list, dists_url in slots:
		php_data = await hub.pkgtools.fetch.get_page(php_url.format(slot=slot), is_json=True)
		patches = "(\n"
		for patch in patch_list:
			patches += '\t"${FILESDIR}/' + patch + '"\n'
		patches += ")"
		if v_spec == "latest":
			upstream_spec = php_data["source"][0]
			version = re.search("([0-9.]+)", upstream_spec["filename"]).groups()[0].rstrip(".")
		else:
			version = v_spec
		if dists_url is None:
			dists_url = f"https://www.php.net/distributions/php-{version}.tar.bz2"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			template=f"php-{slot}.tmpl",
			version=version,
			slot=slot,
			patches=patches,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=dists_url)],
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
