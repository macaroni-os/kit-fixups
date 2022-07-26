#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	github_user = "lkrg-org"
	github_repo = "lkrg"
	parsed_json = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags",
		is_json=True,
	)
	latest_item = parsed_json[0]
	tag = latest_item["name"]
	version = tag[1:]  # strip leading 'v'

	url = f"https://lkrg.org/download/lkrg-{version}.tar.gz"
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
