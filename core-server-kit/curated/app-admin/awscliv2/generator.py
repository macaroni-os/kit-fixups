#!/usr/bin/python3

from packaging import version

async def generate(hub, **pkginfo):
	github_user = pkginfo.get("github_user")
	github_repo = pkginfo.get("github_repo") or pkginfo.get("name")

	pkgmetadata = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}",
		is_json=True,
	)

	if github_repo == "aws-crt-python":
		newpkginfo = await hub.pkgtools.github.release_gen(hub, github_user, github_repo)
		artifacts = [newpkginfo['artifacts'][0]]
		version = newpkginfo['version']

		deplist = []
		for repo in pkginfo.get("aws-c"):
			if type(repo) is dict:
				pkg = list(repo.items())[0]
				ghrepo, ghuser = pkg
				ghuser = ghuser["github_user"]
			else:
				ghuser = github_user
				ghrepo = repo

			newpkginfo = await hub.pkgtools.github.release_gen(hub, ghuser, ghrepo, include={"prerelease"})
			artifacts.append(newpkginfo['artifacts'][0])
			deplist.append(ghrepo.replace('-tls', ''))

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			description=pkgmetadata["description"],
			artifacts=artifacts,
			version=version,
			deplist=deplist,
			github_repo=github_repo
		)
	else: # github_repo == "aws-cli"
		newpkginfo = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo)
		pkginfo.update(newpkginfo)

		pkgmetadata = await hub.pkgtools.fetch.get_page(
			f"https://api.github.com/repos/{github_user}/{github_repo}",
			is_json=True,
		)

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			description=pkgmetadata["description"],
		)

	ebuild.push()

# vim: ts=4 sw=4 noet
