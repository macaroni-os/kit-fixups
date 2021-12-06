#!/usr/bin/env python3

from bs4 import BeautifulSoup


async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)


async def get_bashcomp_artifact():
	github_user = "deepayan"
	github_repo = "rcompletion"

	commits_data = await query_github_api(github_user,github_repo, "commits")
	commit_data = commits_data[0]

	bashcomp_sha = commit_data["sha"]
	final_name = f"{github_repo}-{bashcomp_sha}.tar.gz"
	src_url = f"https://github.com/{github_user}/{github_repo}/archive/{bashcomp_sha}.tar.gz"
	return hub.pkgtools.ebuild.Artifact(url=src_url, final_name=final_name), bashcomp_sha


async def generate(hub, **pkginfo):
	url = "https://cran.r-project.org/src/base/R-4/"
	html_data = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html_data, "html.parser")
	best_archive = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.startswith("R") and href.endswith(".tar.gz"):
			best_archive = href
	version = best_archive.split(".tar")[0].split("-")[1]

	bcartifact, bashcomp_sha = await get_bashcomp_artifact()

	# fetch bash completion file
	#hub.pkgtools.ebuild.Artifact(url=
	#		/{}/bash_completion/R")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, bashcomp_sha=bashcomp_sha, artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url + f"{best_archive}"),
			bcartifact
			]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
