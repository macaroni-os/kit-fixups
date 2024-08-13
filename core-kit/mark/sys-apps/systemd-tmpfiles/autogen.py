#!/usr/bin/env python

from packaging import version


async def generate(hub, **pkginfo):
	github_user = "systemd"
	github_repo = "systemd-stable"

	pkginfo.update(await hub.pkgtools.github.tag_gen(hub, github_user, github_repo, transform=lambda x: x.replace("-rc","_rc")))

	available_build_options = await hub.pkgtools.meson.get_build_options_from_artifact(pkginfo["artifacts"][0])
	boolean_build_options = (
		build_option.name for build_option in available_build_options if
		build_option.type in [
			hub.pkgtools.meson.MesonBuildOptionType.BOOLEAN,
			hub.pkgtools.meson.MesonBuildOptionType.COMBO
		] and (not build_option.choices or "false" in build_option.choices)
	)

	disable_boolean_build_options = "\n\t\t".join([f"-D{option}=false" for option in boolean_build_options])

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		disable_boolean_build_options=disable_boolean_build_options
	)
	ebuild.push()
