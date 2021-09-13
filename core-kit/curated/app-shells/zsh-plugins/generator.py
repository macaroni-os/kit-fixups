#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "zsh-users"
	repo = pkginfo["name"]
	tags_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True)
	valid_tags = (tag for tag in tags_data if "alpha" not in tag["name"])
	latest_tag = next(valid_tags)
	version = latest_tag["name"].lstrip("v")
	url = latest_tag["tarball_url"]
	final_name = f"{repo}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=user,
		github_repo=repo,
		artifacts=[src_artifact],
	)
	ebuild.push()
