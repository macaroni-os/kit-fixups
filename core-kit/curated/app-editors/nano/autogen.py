#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):

	try:
		tags_html = await hub.pkgtools.fetch.get_page(f"https://git.savannah.gnu.org/cgit/nano.git/refs/tags", is_json=False)
	except:
		pass

	if tags_html is None:
		raise hub.pkgtools.ebuild.BreezyError("Can't find nano tags :(")

	match = re.search("cgit\/nano\.git\/tag\/\?h=v([0-9\.]+)", tags_html)

	if match is not None:
		version = match.group(1)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"https://www.nano-editor.org/dist/latest/nano-{version}.tar.gz")],
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
