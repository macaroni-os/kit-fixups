from packaging.specifiers import SpecifierSet
from packaging.version import Version

async def generate(hub, **pkginfo):
	supported_releases = {
		# Current LTS release
		'2.13': '>=2.12,<2.14',
		'2.17': '>=2.17,<2.18',
		'2.16': '>=2.16,<2.17',
		'2.15': '>=2.15,<2.16',
	}
	github_user = "openvswitch"
	github_repo = "ovs"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	handled_releases=[]

	for rel in json_list:
		selectedVersion = None
		version = rel["name"][1:]

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
		url=f"https://www.openvswitch.org/releases/openvswitch-{pv}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)
		ebuild.push()
