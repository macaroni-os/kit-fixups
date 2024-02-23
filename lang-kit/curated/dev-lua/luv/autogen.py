#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	luv_user = "luvit"
	luv_repo = pkginfo["name"]
	pkginfo.update(await hub.pkgtools.github.release_gen(hub, luv_user, luv_repo))
	luacompat_user = "keplerproject"
	luacompat_repo = "lua-compat-5.3"
	luacompat_info = await hub.pkgtools.github.release_gen(hub, luacompat_user, luacompat_repo)
	pkginfo['luacompat_version'] = luacompat_info['version']
	pkginfo['artifacts'] += luacompat_info['artifacts']
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()
