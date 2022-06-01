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
	# vulkan-layers: this has semi-independent versioning (can trail headers + loader a bit)
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
	tag_info = await hub.pkgtools.github.tag_gen(hub, **layers_pkginfo)
	layers_pkginfo.update(tag_info)
	hub.pkgtools.ebuild.BreezyBuild(**layers_pkginfo).push()

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

	##################################################################################################
	# glslang: This also has independent versioning.
	##################################################################################################

	glslang_pkginfo = {
		**khronos_pkginfo,
		'github_repo': 'glslang',
		'cat': 'dev-util',
		'name': 'glslang',
		'template_path': loader.template_path
	}
	# The tags for this on github are messy
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{glslang_pkginfo['github_user']}/{glslang_pkginfo['github_repo']}/tags?per_page=100", is_json=True
	)
	# We are looking only for tags that look like version numbers, and ignoring any tags with letters
	for tag in json_list:
		if any(c.isalpha() for c in tag["name"]):
			continue
		version = tag["name"]
		url = tag["tarball_url"]
		break
	glslang_pkginfo.update(await hub.pkgtools.github.tag_gen(hub, **glslang_pkginfo, select=f"{version}"))
	hub.pkgtools.ebuild.BreezyBuild(**glslang_pkginfo).push()



# vim: ts=4 sw=4 noet
