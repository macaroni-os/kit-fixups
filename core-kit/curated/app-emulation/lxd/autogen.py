from packaging.specifiers import SpecifierSet
from packaging.version import Version

async def generate(hub, **pkginfo):
	supported_releases = {
		'latest': '>=5.3',
		'5.5' : '~=5.5',
		'5.0.x': '~=5.0.0',
	}
	unmasked_releases = [ '5.5', '5.0.x' ]
	github_user = "lxc"
	github_repo = "lxd"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	handled_releases=[]

	for rel in json_list:
		selectedVersion = None
		version = rel["tag_name"][4:]
		if len(supported_releases) == 0:
			break

		v1 = Version(version)
		for k, v in supported_releases.items():
			selector = SpecifierSet(v)
			if v1 in selector:
				selectedVersion = k
				break

		if selectedVersion:
			handled_releases.append((version, True if k in unmasked_releases else False))
			del supported_releases[k]
			continue

		# skip release if {version} contains prerelease string
		skip = len(list(filter(lambda n: n > -1, map(lambda s: version.find(s), ["alpha", "beta", "rc"])))) > 0
		if skip:
			continue

	artifacts = []
	for pv, unmasked in handled_releases:
		url=f"https://linuxcontainers.org/downloads/{github_repo}/lxd-{pv}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
			unmasked=unmasked
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
