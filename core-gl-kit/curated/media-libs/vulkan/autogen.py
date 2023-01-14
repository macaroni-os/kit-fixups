#!/usr/bin/env python3

import os
import glob
import json
from datetime import datetime
from packaging import version
catpkgs = {
	'Vulkan-ValidationLayers': {
		'cat' : 'media-libs',
		'name' : 'vulkan-layers',
		'query': 'tags',
		'select': "v.*",
		'parsedeps': True,
		'deps': ['glslang', 'SPIRV-Tools', 'Vulkan-Headers'],
		'version' : '1.3.236'
	},
	'Vulkan-Tools': {
		'cat' : 'dev-util',
		'name' : 'vulkan-tools',
		'query': 'tags',
		'select': "v.*",
		'parsedeps': True,
		'version' : '1.3.236'
	},
	'Vulkan-Loader': {
		'cat': 'media-libs',
		'name': 'vulkan-loader',
		'query': 'tags',
		'select': "v.*",
		'deps': ['Vulkan-Headers'],
		'pdeps': ['Vulkan-ValidationLayers'],
		'version' : '1.3.236'
	},
	'Vulkan-Headers': {
		'cat': 'dev-util',
		'name': 'vulkan-headers',
		'query': 'tags',
		'select': "v.*",
		'version' : '1.3.236'
	},
	'SPIRV-Tools': {
		'cat': 'dev-util',
		'name': 'spirv-tools',
		'query': 'releases',
		'deps': ['SPIRV-Headers'],
		'version': '2022.2'
	},
	'SPIRV-Headers': {
		'cat': 'dev-util',
		'name': 'spirv-headers',
		'query': 'tags',
		'select': "sdk-.*",
		'version' : '1.3.236.0'
	},
	'glslang': {
		'cat': 'dev-util',
		'name': 'glslang',
		'query': 'tags',
		'select': "sdk-.*",
		'version' : '1.3.236.0'
	},
}

async def generate(hub, **pkginfo):
	# github generators
	github_gen = {
		'tags': hub.pkgtools.github.tag_gen,
		'releases': hub.pkgtools.github.release_gen,
	}

	khronos_pkginfo = {
		'github_user' : 'KhronosGroup',
		'python_compat' : 'python3+',
		'template_path': os.path.normpath(os.path.join(os.path.dirname(__file__), 'templates')),
	}

	# Run through all the catpkgs and record all the versions and details needed to generate ebuilds
	for name in catpkgs:
		catpkg_info = {
			**khronos_pkginfo,
			'github_repo' : name,
			**pkginfo,
		}

		if name == "glslang":
			revision = { "1.3.231.0_p20221013": 1 }
			catpkg_info['revision'] = revision

		catpkg_info.update(catpkgs[name])
		print(f"Processing {catpkg_info['name']}")
		catpkg_info.update(await github_gen[catpkg_info['query']](hub, **catpkg_info))

		if 'parsedeps' in catpkg_info:
			# this is a top-level ebuild and it determines the versions for subsequent ebuilds
			await process_json_deps(**catpkg_info)

		# Sometimes a git commit is specified in the dependencies file
		if 'commit' in catpkg_info:
			# So, find the latest release or tag and then append a suffix reflecting the commit's date
			catpkg_info.update(await process_commit_pkg(**catpkg_info))

		# Finally, update the catpkgs object with all the details from here
		catpkgs[name].update(catpkg_info)


	# Generate all the ebuilds, creating dependency strings on the fly
	for name in catpkgs:
		catpkg = catpkgs[name]
		for depstr in ['deps', 'pdeps']:
			if depstr in catpkg:
				deps = [create_dependency_string(**catpkgs[dep]) for dep in catpkg[depstr]]
				catpkg[depstr] = deps
		hub.pkgtools.ebuild.BreezyBuild(**catpkg).push()

###################################
# Helper Functions
###################################

###
# Create a portage compatible dependency string for a given catpkg
###
def create_dependency_string(**pkginfo):
	if 'version' in pkginfo:
		return f"={pkginfo['cat']}/{pkginfo['name']}-{pkginfo['version']}*"
	return f"{pkginfo['cat']}/{pkginfo['name']}"

###
# Get all the pkginfo details for a package based on a specific git commit hash
###
async def process_commit_pkg(**pkginfo):
	github_user = pkginfo['github_user']
	github_repo = pkginfo['github_repo']
	github_commit = pkginfo['commit']
	commit_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/commits/{github_commit}", is_json=True)
	commit_date = datetime.strptime(commit_data["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	url = f"https://github.com/{github_user}/{github_repo}/archive/{github_commit}.tar.gz"
	pkginfo['version'] += "_p" + commit_date.strftime("%Y%m%d")

	final_name = f"{pkginfo['name']}-{pkginfo['version']}.tar.gz"
	pkginfo['artifacts'] = [hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	return pkginfo


###
# Find the dependency versions located in the file named 'scrips/known_good.json' in the source
###
async def process_json_deps(**pkginfo):
	await pkginfo['artifacts'][0].fetch()
	pkginfo['artifacts'][0].extract()

	path = glob.glob(os.path.join(
		pkginfo['artifacts'][0].extract_path,
		f"{pkginfo['github_user']}-{pkginfo['github_repo']}-*",
		"scripts",
		"known_good.json"
	))

	with open(path[0]) as depsfile:
		data = depsfile.read()

	pkgs = json.loads(data)['repos']
	for pkg in pkgs:
		if 'build_platforms' in pkg and not 'linux' in pkg['build_platforms']:
			continue
		name = pkg['name']
		commit = pkg['commit']
		if name in catpkgs:
			try:
				catpkgs[name]['version'] = version.Version(commit).public
			except version.InvalidVersion:
				catpkgs[name]['commit'] = commit

	pkginfo['artifacts'][0].cleanup()



# vim: ts=4 sw=4 noet
