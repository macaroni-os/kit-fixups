#!/usr/bin/env python3


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)


async def generate(hub, **pkginfo):
	github_user = "ImageMagick"
	github_repo = "ImageMagick"
	json_data = await query_github_api(github_user, github_repo, "releases")
	for release in json_data:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"].lstrip("v")
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	version = version.replace("-",".")
	await artifact.fetch()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		major_ver=version.split(".")[0],
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
