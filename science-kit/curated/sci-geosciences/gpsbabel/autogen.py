#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	github_user = "GPSBabel"
	github_repo = "gpsbabel"
	css_url = f"https://www.gpsbabel.org/style3.css"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for release in json_list:
		if not release["name"].startswith('gpsbabel_'):
			continue
		version = release["name"].split("gpsbabel_")[1].replace('_','.')
		source_url = release["tarball_url"]
		break
	final_name=f"gpsbabel-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=source_url, final_name=final_name),
			hub.pkgtools.ebuild.Artifact(url=css_url, final_name='gpsbabel.org-style3.css'),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
