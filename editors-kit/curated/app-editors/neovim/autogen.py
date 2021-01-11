#!/usr/bin/env python3

import re


def get_release(release_data, is_stable=True):
	releases = list(filter(lambda x: x["prerelease"] != is_stable, release_data))
	return None if not releases else sorted(releases, key=lambda x: x["tag_name"]).pop()


def generate_ebuild(hub, repo_name, release_data, is_stable, **pkginfo):
	curr_release = get_release(release_data, is_stable)
	if curr_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo_name}")
	tag = curr_release["tag_name"]
	# version = curr_release["name"].split(" ")[-1].split("-")[0].lstrip("v")
	version = re.sub("[^0-9.]", "", curr_release["name"])
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		stable=is_stable,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{repo_name}/{repo_name}/archive/{tag}.tar.gz",
				final_name=f"{repo_name}-{version}.tar.gz",
			)
		],
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	name = pkginfo["name"]
	release_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{name}/{name}/releases", is_json=True)

	generate_ebuild(hub, name, release_data, True, **pkginfo)
	# FL-7926 - previous (NVIM NVIM 0.5.095053284) unstable version has been
	# removed from github
	# generate_ebuild(hub, name, release_data, False, **pkginfo)
