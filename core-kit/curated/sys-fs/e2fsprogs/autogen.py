#!/usr/bin/env python3


async def generate(hub, **pkginfo):

	github_user = "tytso"
	github_repo = "e2fsprogs"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag in json_list:
		version = tag["name"].replace("v", "")
		url = f"https://www.kernel.org/pub/linux/kernel/people/{github_user}/{github_repo}/v{version}/{app}-{version}.tar.xz"
		break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()
	ebuild_libs = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		cat="sys-libs",
		name="e2fsprogs-libs",
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild_libs.push()


# vim: ts=4 sw=4 noet
