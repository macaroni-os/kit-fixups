from packaging.specifiers import SpecifierSet
from packaging.version import Version

async def generate(hub, **pkginfo):
	github_user = "mirror"
	github_repo = "busybox"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	for rel in json_list:
		version = rel["name"]
		if 'tarball_url' in rel:
			url = rel['tarball_url']

		if version != "":
			break

	pv = version.replace("_", ".")
	# We can just using ebuild directly for the SRC_URI
	#url=f"https://github.com/{github_user}/{github_repo}/archive/refs/tags/{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=pv,
		github_user=github_user,
		github_repo=github_repo,
		#artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		artifacts=[],
	)
	ebuild.push()
