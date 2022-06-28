#!/usr/bin/env python3


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)


async def generate(hub, **pkginfo):
	github_user = "mean00"
	github_repo = "avidemux2"
	json_data = await query_github_api(github_user, github_repo, "releases")
	for release in json_data:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)

	github_i18n = "avidemux2_i18n"
	json_i18n = await query_github_api(github_user, github_i18n, "tags")
	for tag in json_i18n:
		i18n_version = tag["name"]
		i18n_url = tag["tarball_url"]
		break
	i18n_final_name = f'{pkginfo["name"]}-i18n-{i18n_version}.tar.gz'
	i18n_artifact = hub.pkgtools.ebuild.Artifact(url=i18n_url, final_name=i18n_final_name)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		github_i18n=github_i18n,
		artifacts=[
			artifact,
			i18n_artifact,
		],
	)
	ebuild.push()

	ebuild_core = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		cat="media-libs",
		name="avidemux-core",
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[artifact],
	)
	ebuild_core.push()

	ebuild_plugins = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild.template_path,
		cat="media-libs",
		name="avidemux-plugins",
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[artifact],
	)
	ebuild_plugins.push()


# vim: ts=4 sw=4 noet
