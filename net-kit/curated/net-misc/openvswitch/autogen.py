from packaging.specifiers import SpecifierSet
from metatools.version import generic

async def generate(hub, **pkginfo):
	supported_releases = {
		# Current LTS release
		'2.13': { 'selector': '>=2.12,<2.14' },
		'2.17': { 'selector': '>=2.17,<2.18' },
		'2.16': { 'selector': '>=2.16,<2.17' },
		'2.15': { 'selector': '>=2.15,<2.16' },
		# New Release
		'3.0': { 'selector': '>=3.0,<3.1', 'template': 'openvswitch3.tmpl' },
	}
	github_user = "openvswitch"
	github_repo = "ovs"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	handled_releases=[]

	for rel in json_list:
		selectedVersion = None
		overrideTemplate = False
		version = rel["name"][1:]

		if len(supported_releases) == 0:
			break

		v1 = generic.parse(version)
		for k, v in supported_releases.items():
			selector = SpecifierSet(v['selector'])
			if v1 in selector:
				selectedVersion = k
				break

		if selectedVersion:
			template = supported_releases[selectedVersion]['template'] \
				if 'template' in supported_releases[selectedVersion] else None
			handled_releases.append({
				'version':version,
				'template': template,
			})
			del supported_releases[k]
			continue

		# skip release if {version} contains prerelease string
		skip = len(list(filter(lambda n: n > -1, map(lambda s: version.find(s), ["alpha", "beta", "rc"])))) > 0
		if skip:
			continue

	artifacts = []
	for pvdata in handled_releases:
		pv=pvdata['version']
		url=f"https://www.openvswitch.org/releases/openvswitch-{pv}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			template=pvdata['template'],
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)
		ebuild.push()
