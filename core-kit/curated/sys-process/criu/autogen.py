#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	github_user = "checkpoint-restore"
	github_repo = "criu"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True)
	for tag in json_data:
		tag_name = tag['name']
		version = tag_name.lstrip('v')
		commit_sha = tag['commit']['sha']
		# This is a github trick. If you know the tag, you can grab a tarball via sha1, which is safest:
		# https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#download-a-repository-archive-tar
		final_name = f'{github_repo}-{version}-{commit_sha[:7]}.tar.gz'
		url = f'https://api.github.com/repos/{github_user}/{github_repo}/tarball/{commit_sha}'
		break
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		commit_sha=commit_sha,
		artifacts=[artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
