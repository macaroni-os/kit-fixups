from packaging.specifiers import SpecifierSet
from packaging.version import Version

async def generate(hub, **pkginfo):
    # NOTE: Disable 3.9 for now that fail in compilation.
    #       Arangodb requires gcc >=9.3 but 3.7 and 3.8
    #       works.
	supported_releases = {
		#'3.9': '>=3.9,<3.10',
		'3.8': '>=3.8,<3.9',
		'3.7': '>=3.7,<3.8',
	}
	github_user = "arangodb"
	github_repo = "arangodb"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	handled_releases=[]

	for rel in json_list:
		selectedVersion = None
		version = rel["name"][1:]

		# Drop garbage version (like vdevel)
		if version[0:1] != "3":
			continue

		if len(supported_releases) == 0:
			break

		v1 = Version(version)
		for k, v in supported_releases.items():
			selector = SpecifierSet(v)
			if v1 in selector:
				selectedVersion = k
				break

		if selectedVersion:
			handled_releases.append(version)
			del supported_releases[k]
			continue

		# skip release if {version} contains prerelease string
		skip = len(list(filter(lambda n: n > -1, map(lambda s: version.find(s), ["alpha", "beta", "rc"])))) > 0
		if skip:
			continue

	artifacts = []
	for pv in handled_releases:
		url=f"https://github.com/{github_repo}/{github_user}/archive/v{pv}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)
		ebuild.push()
