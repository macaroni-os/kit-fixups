#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	github_user = "mgorny"
	github_repo = "eselect-repository"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	latest = json_list[0]
	version = latest["name"]
	url = latest["tarball_url"]
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version.lstrip("v"),
        revision={"13": "1"},
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()
