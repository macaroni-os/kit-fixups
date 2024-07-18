#!/usr/bin/python3

# This generator is designed to generate two ebuilds, one a foo-compat ebuild that provides python2.7 compatibility,
# and the other a foo ebuild that provides python3 compatibility. But the foo ebuild will 'advertise' python2.7
# compatibility as well, and if enabled, it will RDEPEND on foo-compat.
#
# This will allow packages that still expect foo to work with python2.7 to continue to be able to depend upon foo.
# Everything should still work.
#
# When upgrading from an older 'classic' ebuild that has python2.7 compatibility, first the foo ebuild will be
# merged, which will jettison 2.7 support, but immediately afterwards, foo-compat will be merged if needed and
# 2.7 compatibility will be back.

import glob
import os
import toml

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}

def get_extensions(pkginfo):
	es = []
	valid_extensions = {
		"local-only" : "We have the sources locally -- don't query pypi -- don't create a SRC_URI.",
		"rust": "Modern rust support",
		"golang": "Go language support"
	}
	ext_set = set()
	if "extensions" in pkginfo:
		es = pkginfo["extensions"]
		for e in es:
			if e not in valid_extensions:
				raise ValueError(f"'{e}' is not a valid extension for the pypi-compat-1 generator.")
			ext_set.add(e)
	return ext_set


async def add_ebuild(hub, json_dict=None, compat_ebuild=False, has_compat_ebuild=False, **pkginfo):
	"""
	has_compat_ebuild is a boolean that lets us know, when we're creating the non-compat ebuild --
	will we be creating a compat ebuild also? Because we do special filtering on python_compat
	in this case.
	"""
	if "extensions" in pkginfo:
		extensions = pkginfo["extensions"]
	else:
		extensions = set()
	if "iuse" in pkginfo:
		if isinstance(pkginfo["iuse"], str):
			pkginfo["iuse"] = pkginfo["iuse"].split()
	else:
		pkginfo["iuse"] = []

	local_pkginfo = pkginfo.copy()
	assert "python_compat" in local_pkginfo, f"python_compat is not defined in {local_pkginfo}"
	local_pkginfo["compat_ebuild"] = compat_ebuild
	if "local-only" not in extensions:
		hub.pkgtools.pyhelper.pypi_metadata_init(local_pkginfo, json_dict)
	else:
		local_pkginfo["inherit"] = [ "distutils-r1" ]
	hub.pkgtools.pyhelper.expand_pydeps(local_pkginfo, compat_mode=True, compat_ebuild=compat_ebuild)
	if compat_ebuild:
		local_pkginfo["python_compat"] = "python2_7"
		if isinstance(local_pkginfo["compat"], str):
			# assume compat is just the compat version
			hub.pkgtools.model.log.debug(f"For compat ebuild, setting version to {local_pkginfo['compat']}")
			local_pkginfo["version"] = local_pkginfo["compat"]
		else:
			# assume we are overriding more things
			local_pkginfo.update(local_pkginfo["compat"])
		local_pkginfo["name"] = local_pkginfo["name"] + "-compat"
		if "du_pep517" in local_pkginfo:
			# It doesn't make sense to enable new PEP 517 support for python2.7-compat ebuilds:
			del local_pkginfo["du_pep517"]
		if "local-only" not in extensions:
			artifact_url = hub.pkgtools.pyhelper.pypi_get_artifact_url(local_pkginfo, json_dict, has_python="2.7", strict=True)
	else:
		if has_compat_ebuild:
			local_pkginfo["iuse"] += ["python_targets_python2_7"]
			compat_split = local_pkginfo["python_compat"].split()
			new_compat_split = []
			for compat_item in compat_split:
				if compat_item == "python2+":
					# Since we're making a compat ebuild, we really don't want our main ebuild to advertise py2 compat.
					new_compat_split.append("python3+")
				else:
					new_compat_split.append(compat_item)
			local_pkginfo["python_compat"] = " ".join(new_compat_split)
		if "version" in local_pkginfo and local_pkginfo["version"] != "latest":
			version_specified = True
		else:
			version_specified = False
			# get latest version
			local_pkginfo["version"] = json_dict["info"]["version"]
		if "requires_python_override" in local_pkginfo:
			# Allow YAML to override bogus upstream pypi requires_python settings:
			requires_python_override = local_pkginfo["requires_python_override"]
		else:
			# Use upstream values:
			requires_python_override = None
		python_kit = hub.release_yaml.get_primary_kit(name="python-kit")
		has_python = python_kit.settings["has_python"]
		if "local-only" not in extensions:
			artifact_url = hub.pkgtools.pyhelper.pypi_get_artifact_url(local_pkginfo, json_dict, strict=version_specified, has_python=has_python,
							requires_python_override=requires_python_override)
	# fixup $S automatically -- this seems to follow the name in the archive:
	artifacts = []
	if "local-only" in extensions:
		# Allow pypi_name to allow renaming of the expected S dir, even if we are grabbing ebuild from a local archive.
		if "pypi_name" in pkginfo:
			local_pkginfo["s_pkg_name"] = pkginfo["pypi_name"]
	else:
		under_name = pkginfo["name"].replace("-", "_")
		over_name = pkginfo["name"].replace("_", "-")
		local_pkginfo["s_pkg_name"] = pkginfo["pypi_name"]
		hub.pkgtools.pyhelper.pypi_normalize_version(local_pkginfo)
		artifact = hub.pkgtools.ebuild.Artifact(url=artifact_url)
		await artifact.fetch()
		if "golang" in extensions:
			await hub.pkgtools.golang.add_gosum_bundle(hub, local_pkginfo, src_artifact=artifact)
		if "rust" in extensions:
			await hub.pkgtools.rust.add_crates_bundle(hub, local_pkginfo, src_artifact=artifact)
		artifact.extract()
		main_dir = glob.glob(os.path.join(artifact.extract_path, "*"))
		if len(main_dir) != 1:
			raise ValueError("Found more than one directory inside python module")
		main_dir = main_dir[0]
		main_base = os.path.basename(main_dir)
		artifacts = [ artifact ]
		# deal with fact that "-" and "_" are treated as equivalent by pypi:
		if not main_base.startswith(pkginfo["name"]):
			if main_base.startswith(under_name):
				local_pkginfo["s_pkg_name"] = under_name
			elif main_base.startswith(over_name):
				local_pkginfo["s_pkg_name"] = over_name

		assert (
			artifact_url is not None
		), f"Artifact URL could not be found in {pkginfo['name']} {local_pkginfo['version']}. This can indicate a PyPi package without a 'source' distribution."

		if not compat_ebuild and "du_pep517" in local_pkginfo and local_pkginfo["du_pep517"] == "generator":
			del local_pkginfo["du_pep517"]
			hub.pkgtools.model.log.debug("Auto-detecting du_pep517 setting...")
			setup_path = glob.glob(os.path.join(artifact.extract_path, "*", "setup.py"))
			if len(setup_path):
				has_setup = True
			else:
				has_setup = False
			pyproject_path = glob.glob(os.path.join(artifact.extract_path, "*", "pyproject.toml"))
			found_build_system = None
			extra_bdeps = []
			if len(pyproject_path):
				with open(pyproject_path[0], "r") as f:
					try:
						toml_data = toml.load(f)
					except toml.TomlDecodeError as e:
						hub.pkgtools.model.log.error(f"TOML decode error for {pkginfo['name']}: {repr(e)}")
						toml_data = {}
					if "build-system" not in toml_data:
						pass
					elif "requires" not in toml_data["build-system"]:
						pass
					else:
						# NOTE: detect 'hatch-vcs' and add it directly as a build dep rather than using the eclass.
						#       We can do this more in the future to get rid of the eclass if we want.
						for req in toml_data["build-system"]["requires"]:
							if req.startswith("flit_core"):
								found_build_system = "flit"
								break
							elif req.startswith("hatchling"):
								found_build_system = "hatchling"
							elif req.startswith("hatch-vcs"):
								extra_bdeps.append('hatch-vcs')
							elif req.startswith("setuptools-scm") or req.startswith("setuptools_scm"):
								found_build_system = "setuptools"
								if "depend" not in local_pkginfo:
									local_pkginfo["depend"] = ""
								else:
									local_pkginfo["depend"] += "\n"
								local_pkginfo["depend"] += 'dev-python/setuptools_scm[${PYTHON_USEDEP}]\n'
							elif req.startswith("setuptools"):
								found_build_system = "setuptools"
							elif req.startswith("poetry"):
								found_build_system = "poetry"
			if found_build_system is None:
				if has_setup:
					hub.pkgtools.model.log.info("Falling back to legacy setuptools, due to no build-system defined in pyproject.toml.")
				else:
					raise ValueError(f"{local_pkginfo['name']}: Could not auto-detect build system in pyproject.toml.")
			else:
				local_pkginfo["du_pep517"] = found_build_system
				if extra_bdeps:
					if "depend" not in local_pkginfo:
						local_pkginfo["depend"] = ""
					local_pkginfo["depend"] += "\n".join(map(lambda x: hub.pkgtools.pyhelper.expand_pydep(local_pkginfo, x), extra_bdeps))

	if "template" in pkginfo:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**local_pkginfo,
		)
	else:
		local_pkginfo["template_path"] = os.path.normpath(os.path.join(os.path.dirname(__file__), "templates"))
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**local_pkginfo,
			template="pypi-compat-1.tmpl"
		)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**local_pkginfo,
		template="pypi-compat-1.tmpl"
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	extensions = pkginfo["extensions"] = get_extensions(pkginfo)
	if "local-only" not in extensions:
		pypi_name = hub.pkgtools.pyhelper.pypi_normalize_name(pkginfo)
		json_dict = await hub.pkgtools.fetch.get_page(
			f"https://pypi.org/pypi/{pypi_name}/json", refresh_interval=pkginfo["refresh_interval"], is_json=True
		)
	else:
		json_dict = None
	if "inherit" not in pkginfo:
		pkginfo["inherit"] = []
	do_compat_ebuild = "compat" in pkginfo and pkginfo["compat"]
	await add_ebuild(hub, json_dict, compat_ebuild=False, has_compat_ebuild=do_compat_ebuild, **pkginfo)
	if do_compat_ebuild:
		await add_ebuild(hub, json_dict, compat_ebuild=True, **pkginfo)


# vim: ts=4 sw=4 noet
