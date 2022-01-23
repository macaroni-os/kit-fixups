#!/usr/bin/env python3

async def generate(hub, **pkginfo):

	khronos_pkginfo = {
		'github_user' : 'KhronosGroup',
		'python_compat' : 'python3+'
	}

	##################################################################################################
	# vulkan-loader is the 'master' ebuild which defines the version for all the other vulkan ebuilds:
	##################################################################################################

	loader_pkginfo = {
		**khronos_pkginfo,
		'github_repo' : 'Vulkan-Loader'
	}
	loader_pkginfo.update(await hub.pkgtools.github.tag_gen(hub, **loader_pkginfo))
	loader_pkginfo.update({
		**pkginfo
	})
	loader_pkginfo['name'] = 'vulkan-loader'
	loader = hub.pkgtools.ebuild.BreezyBuild(**loader_pkginfo)
	loader.push()
	ver = loader_pkginfo['version']

	##################################################################################################
	# vulkan-layers: track loader version.
	##################################################################################################

	layers_pkginfo = {
		**khronos_pkginfo,
		'github_repo' : 'Vulkan-ValidationLayers',
		'version' : ver,
		'cat' : 'media-libs',
		'name' : 'vulkan-layers',
		'template_path' : loader.template_path,
		'revision' : { '1.2.203' : '1' }
	}
	layers_pkginfo.update(await hub.pkgtools.github.tag_gen(hub, **layers_pkginfo, select=f"v{ver}"))
	hub.pkgtools.ebuild.BreezyBuild(**layers_pkginfo).push()

	##################################################################################################
	# vulkan-headers: track loader version.
	##################################################################################################

	headers_pkginfo = {
		**khronos_pkginfo,
		'github_repo' : 'Vulkan-Headers',
		'version' : ver,
		'cat' : 'dev-util',
		'name' : 'vulkan-headers',
		'template_path' : loader.template_path
	}
	headers_pkginfo.update(await hub.pkgtools.github.tag_gen(hub, **headers_pkginfo, select=f"v{ver}"))
	hub.pkgtools.ebuild.BreezyBuild(**headers_pkginfo).push()

	##################################################################################################
	# vulkan-tools: This has independent versioning.
	##################################################################################################

	tools_pkginfo = {
		**khronos_pkginfo,
		'github_repo' : 'Vulkan-Tools',
		'version' : ver,
		'cat' : 'dev-util',
		'name' : 'vulkan-tools',
		'template_path' : loader.template_path
	}
	tools_pkginfo.update(await hub.pkgtools.github.tag_gen(hub, **tools_pkginfo, select=f"v.*"))
	hub.pkgtools.ebuild.BreezyBuild(**tools_pkginfo).push()



# vim: ts=4 sw=4 noet
