import os
import subprocess

from packaging.specifiers import SpecifierSet
from packaging.version import Version

# Unlucky I haven't found a way to retrieve the submodule hash commit
# directly through github API. I will clone the repository and
# i will read the submodule hash.
def get_ovs_hash(version, repo, target_dir):
	present = os.path.exists(target_dir)

	if not present:
		res = subprocess.run('git clone %s %s' % (repo, target_dir),
				shell=True)
		if res.returncode != 0:
			print("Error on clone", repo)
			return ""

	res = subprocess.run('git checkout v%s' % version,
			shell=True, cwd=target_dir)
	if res.returncode != 0:
		print('Error on checkout to v%s' % version)
		return ""

	res = subprocess.run('git rev-parse HEAD:ovs',
			shell=True, capture_output=True, cwd=target_dir)
	if res.returncode != 0:
		print('Error on retrieve ovs submodule git hash')
		return ""

	githash = res.stdout.decode("utf-8").strip()
	return githash

async def generate(hub, **pkginfo):
	supported_releases = {
		'22.06': '>=22.06.0,<22.07.0',
		'22.03': '>=22.03.0,<22.04.0',
		'21.12': '>=21.12.0,<22.01.0',
	}
	github_user = "ovn-org"
	github_repo = "ovn"
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
	git_repo = f"https://github.com/{github_user}/{github_repo}.git"
	tmp_dir = '/tmp/ovn/'
	for pv in handled_releases:

		ovs_hash = get_ovs_hash(pv, git_repo, tmp_dir)
		if ovs_hash == "":
			print("ERROR on retrieve hash of ovs repository")
			continue

		url=f"https://github.com/{github_user}/{github_repo}/archive/refs/tags/v{pv}.tar.gz"
		url_ovs=f"https://github.com/openvswitch/ovs/archive/{ovs_hash}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=url),
				hub.pkgtools.ebuild.Artifact(url=url_ovs),
			],
		)
		ebuild.push()

	if len(handled_releases) > 0:
		subprocess.run('rm -rf %s'% tmp_dir, shell=True)
