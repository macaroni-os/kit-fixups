from packaging.specifiers import SpecifierSet
from packaging.version import Version

async def generate(hub, **pkginfo):
	supported_releases = {
		'latest': '>0.3.0',
		'0.3.0': '==0.3.0',
	}
	github_user = "lxc"
	github_repo = "incus"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	handled_releases=[]

	for rel in json_list:
		selectedVersion = None
		version = rel["tag_name"][1:]

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

	artifacts = []
	for pv in handled_releases:

		# Version with patch version zero is generated with only major and minor version.
		# So, version 0.4.0 for example will be 0.4 as tarball.
		v = Version(pv)
		tar_version = pv
		if v.micro == 0:
			tar_version = "%s.%s" % (v.major, v.minor)

		url=f"https://github.com/lxc/incus/releases/download/v{pv}/incus-{tar_version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			tar_version=tar_version,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)
		ebuild.push()
