#!/usr/bin/env python3

from distutils.version import LooseVersion


def get_release(release_data):
	releases = list(
		filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data)
	)
	return (
		None
		if not releases
		else sorted(releases, key=lambda x: LooseVersion(x["tag_name"])).pop()
	)


async def fetch_latest_release(hub, user, repo):
	releases_dict = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
	)
	latest_release = get_release(releases_dict)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	return latest_release["tag_name"]


async def generate(hub, **pkginfo):
	luv_user = "luvit"
	luv_repo = pkginfo["name"]
	luv_version = await fetch_latest_release(hub, luv_user, luv_repo)
	luv_ebuild_version = luv_version.replace("-", ".")
	luacompat_user = "keplerproject"
	luacompat_repo = "lua-compat-5.3"
	luacompat_version = await fetch_latest_release(hub, luacompat_user, luacompat_repo)
	luacompat_ebuild_version = luacompat_version.lstrip("v")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=luv_ebuild_version,
		luacompat_version=luacompat_ebuild_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{luv_user}/{luv_repo}/releases/download/{luv_version}/{luv_repo}-{luv_version}.tar.gz",
				final_name=f"{luv_repo}-{luv_ebuild_version}.tar.gz",
			),
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{luacompat_user}/{luacompat_repo}/archive/{luacompat_version}.tar.gz",
				final_name=f"{luv_repo}-lua-compat-{luacompat_ebuild_version}.tar.gz",
			),
		],
	)
	ebuild.push()
