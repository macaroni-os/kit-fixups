#!/usr/bin/python3


async def generate(hub, **pkginfo):
	for key in ["user", "repo"]:
		if f"github_{key}" not in pkginfo:
			if "github" in pkginfo and key in pkginfo["github"]:
				pkginfo[f"github_{key}"] = pkginfo["github"][key]
			else:
				pkginfo[f"github_{key}"] = pkginfo["name"]

	query = pkginfo["github"]["query"]
	if query not in ["releases", "tags"]:
		raise KeyError(
			f"{pkginfo['cat']}/{pkginfo['name']} should specify GitHub query type of 'releases' or 'tags'."
		)

	github_user = pkginfo["github_user"]
	github_repo = pkginfo["github_repo"]

	if "homepage" not in pkginfo:
		pkginfo["homepage"] = f"https://github.com/{github_user}/{github_repo}"

	if query == "tags":
		github_result = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo)
	else:
		github_result = await hub.pkgtools.github.release_gen(
			hub,
			github_user,
			github_repo,
			tarball=pkginfo.get("tarball", None),
			select=pkginfo.get("select", None),
		)

	if github_result is None:
		raise KeyError(
			f"Unable to find suitable GitHub release/tag for {pkginfo['cat']}/{pkginfo['name']}."
		)

	pkginfo.update(github_result)

	if "description" not in pkginfo:
		repo_metadata = await hub.pkgtools.fetch.get_page(
			f"https://api.github.com/repos/{github_user}/{github_repo}", is_json=True
		)
		pkginfo["description"] = repo_metadata["description"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()


# vim: ts=4 sw=4 noet
