#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
    user = 'arvidn'
    repo = 'libtorrent'
    app = 'libtorrent-rasterbar'
    json_data = await hub.pkgtools.fetch.get_page(f'https://api.github.com/repos/{user}/{repo}/releases/latest')
    json_list = json.loads(json_data)
    tag = json_list['tag_name']
    version = json_list['name'].split('-', 1)[1]
    url = f'https://github.com/{user}/{repo}/archive/{tag}.tar.gz'
    final_name = f'{app}-{version}.tar.gz'

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
    ebuild.push()
