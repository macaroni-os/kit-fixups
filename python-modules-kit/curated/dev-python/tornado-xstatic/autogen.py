#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page('https://api.github.com/repos/takluyver/tornado_xstatic/releases')
	json_dict = json.loads(json_data)
	version = json_dict['info']['version']
	for artifact in json_dict['releases'][version]:
		if artifact['packagetype'] == 'sdist':
			artifact_url = artifact['url']
			break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat='python2_7 python3_{6,7,8}',
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=artifact_url)
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
