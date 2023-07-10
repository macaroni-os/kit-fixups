#!/usr/bin/env python3


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)


async def generate(hub, **pkginfo):
	majors = [ '7', '6' ]
	github_user = "redis"
	github_repo = "redis"
	json_data = await query_github_api(github_user, github_repo, "releases")
	tag_data = await query_github_api(github_user, github_repo, "tags")
	for major in majors:
		tag_name = None
		for release in json_data:
			if release["prerelease"] or release["draft"]:
				continue
			version = release["name"]
			if not version.startswith(f'{major}.'):
				continue
			tag_name = release["tag_name"]
			release_tarball = release["tarball_url"]
			break
		if tag_name is None:
			raise KeyError(f"Could not find a suitable redis {major} release.")
		tag_list = list(filter(lambda x: x["name"] == tag_name, tag_data))
		if len(tag_list) != 1:
			print(f"Could not find suitable tag {tag_name} for redis {major} release -- falling back to release tarball.")
			artifact = hub.pkgtools.ebuild.Artifact(url=release_tarball, final_name=f"redis-{version}.tar.gz")
		else:
			# grab more specific sha-based file from tag.
			commit_sha = tag_list[0]["commit"]["sha"]
			final_name = f'{pkginfo["name"]}-{version}-{commit_sha[:7]}.tar.gz'
			# This is a github trick. If you know the tag, you can grab a tarball via sha1, which is safest:
			url = f'https://github.com/{github_user}/{github_repo}/tarball/{commit_sha}'
			artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			major_ver=major,
			version=version,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[artifact],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
