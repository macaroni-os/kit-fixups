#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	gitlab_user = "Oslandia"
	gitlab_repo = "SFCGAL"

	compression_types = ['tar.xz', 'tar.bz2', 'tar.gz', 'zip'] # in preference order

	json_list = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.com/api/v4/projects/{gitlab_user}%2F{gitlab_repo}/releases", is_json=True
	)

	latest = json_list[0]
	version = latest["name"][1:]
	assets = latest['assets']['sources']

	for compression in compression_types:
		asset = [a for a in assets if a['format'].endswith(compression)]
		if asset:
			url = asset[0]['url']
			final_name = f'{pkginfo["name"]}-{version}.{compression}'
			break


	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		gitlab_user=gitlab_user,
		gitlab_repo=gitlab_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)

	ebuild.push()

# vim:ts=4 sw=4 noet
