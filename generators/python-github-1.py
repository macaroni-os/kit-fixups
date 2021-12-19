#!/usr/bin/python3

import os

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}


async def generate(hub, **pkginfo):
	if "inherit" not in pkginfo:
		pkginfo["inherit"] = []
	if "distutils-r1" not in pkginfo["inherit"]:
		pkginfo["inherit"].append("distutils-r1")
	hub.pkgtools.pyhelper.expand_pydeps(pkginfo)
	for key in ['user', 'repo']:
		if key not in pkginfo:
			if 'github' in pkginfo and key in pkginfo['github']:
				pkginfo[f'github_{key}'] = pkginfo['github'][key]
			else:
				pkginfo[f'github_{key}'] = pkginfo['name']
	query = pkginfo['github']['query']
	if query not in ["releases", "tags"]:
		raise KeyError(f"{pkginfo['cat']}/{pkginfo['name']} should specify GitHub query type of 'releases' or 'tags'.")

	github_user = pkginfo['github_user']
	github_repo = pkginfo['github_repo']
	if 'homepage' not in pkginfo:
		pkginfo['homepage'] = f"https://github.com/{github_user}/{github_repo}"

	if query == "tags":
		github_result = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo)
	else:
		github_result = await hub.pkgtools.github.release_gen(hub, github_user, github_repo, tarball=pkginfo.get('tarball', None))
	if github_result is None:
		raise KeyError(f"Unable to find suitable GitHub release/tag for {pkginfo['cat']}/{pkginfo['name']}.")

	pkginfo.update(github_result)

	if "inherit" in pkginfo and "cargo" in pkginfo["inherit"]:
		cargo_artifacts = await hub.pkgtools.rust.generate_crates_from_artifact(pkginfo['artifacts'][0], "*/src/rust")
		pkginfo["crates"] = cargo_artifacts["crates"]
		pkginfo['artifacts'] += cargo_artifacts["crates_artifacts"]

	pkginfo["template_path"] = os.path.normpath(os.path.join(os.path.dirname(__file__), "templates"))
	pkginfo["template"] = "python-github-1.tmpl"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
