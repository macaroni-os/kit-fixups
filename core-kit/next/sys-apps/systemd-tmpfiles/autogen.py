#!/usr/bin/env python

from packaging import version


async def generate(hub, **pkginfo):
	github_user = "systemd"
	github_repo = "systemd-stable"

	release_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags",
		is_json=True,
	)

	try:
		latest_release = max(
			release_data,
			key=lambda release: version.parse(release["name"]),
		)
	except ValueError:
		raise hub.pkgtools.ebuild.BreezyError(
			f"Can't find suitable release of {github_repo}"
		)

	tag_name = latest_release["name"]
	latest_version = tag_name.lstrip("v").replace("-rc", "_rc")

	source_url = latest_release["tarball_url"]
	source_name = f"{github_repo}-{latest_version}.tar.gz"

	source_artifact = hub.pkgtools.ebuild.Artifact(
		url=source_url, final_name=source_name
	)

	available_build_options = await hub.pkgtools.meson.get_build_options_from_artifact(source_artifact)
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
		version=latest_version,
		artifacts=[source_artifact],
		github_user=github_user,
		github_repo=github_repo,
		disable_boolean_build_options=disable_boolean_build_options
	)
	ebuild.push()
