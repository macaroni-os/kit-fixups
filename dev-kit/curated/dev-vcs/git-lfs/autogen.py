#!/usr/bin/env python3

#!/usr/bin/env python3

from packaging import version

def get_release(release_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()

async def generate(hub, **pkginfo):
	user = pkginfo["name"]
	repo = user
	release_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	latest_release = get_release(release_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	tag = latest_release["tag_name"]
	version = pkginfo["version"] = tag.lstrip("v")
	url = latest_release["tarball_url"]
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	pkginfo['artifacts'] = { 'main' : hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name) }
	await hub.pkgtools.golang.add_gosum_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts']['main'])
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=user,
		github_repo=repo
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
