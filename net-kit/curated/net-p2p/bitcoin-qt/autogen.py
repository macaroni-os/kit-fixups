#!/usr/bin/env python

# Do not attempt to convert this autogen into a github-1 based yaml
# unless you know exactly what you are doing.

# A "bitcoin-core/gui" GitHub repository exists, which considered as
# a "staging repository".  The official source tarballs are published only
# on the bitcoincore.org website and they are not the same as a GitHub tarball.

import re

async def generate(hub, **pkginfo):
	page = await hub.pkgtools.fetch.get_page("https://bitcoincore.org/en/releases/", is_json=False)
	tags = re.findall( "releases\/(\d+\.\d+(?:\.\d+))", page )
	tags.sort( reverse = True )
	version = tags[0]

	artifact= hub.pkgtools.ebuild.Artifact(
		url=f"https://bitcoincore.org/bin/bitcoin-core-{version}/bitcoin-{version}.tar.gz"
	)

	for flavor in ["-qt","-cli","-tx","d"]:
		pkginfo["name"] = f"bitcoin{flavor}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			artifacts = [artifact],
			version = version
			)
		ebuild.push()

# vim: ts=4 sw=4 noet
