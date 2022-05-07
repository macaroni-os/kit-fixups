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

import json
import os
from collections import OrderedDict

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}


async def add_ebuild(hub, json_dict=None, compat_ebuild=False, has_compat_ebuild=False, **pkginfo):
	"""
	has_compat_ebuild is a boolean that lets us know, when we're creating the non-compat ebuild --
	will we be creating a compat ebuild also? Because we do special filtering on python_compat
	in this case.
	"""
	local_pkginfo = pkginfo.copy()
	assert "python_compat" in local_pkginfo, f"python_compat is not defined in {local_pkginfo}"
	local_pkginfo["compat_ebuild"] = compat_ebuild
	hub.pkgtools.pyhelper.pypi_metadata_init(local_pkginfo, json_dict)
	hub.pkgtools.pyhelper.expand_pydeps(local_pkginfo, compat_mode=True, compat_ebuild=compat_ebuild)

	if compat_ebuild:
		local_pkginfo["python_compat"] = "python2_7"
		local_pkginfo["version"] = local_pkginfo["compat"]
		local_pkginfo["name"] = local_pkginfo["name"] + "-compat"
		artifact_url = hub.pkgtools.pyhelper.sdist_artifact_url(json_dict["releases"], local_pkginfo["version"])
	else:
		if has_compat_ebuild:
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

		artifact_url = hub.pkgtools.pyhelper.pypi_get_artifact_url(local_pkginfo, json_dict, strict=version_specified)

	assert (
		artifact_url is not None
	), f"Artifact URL could not be found in {pkginfo['name']} {local_pkginfo['version']}. This can indicate a PyPi package without a 'source' distribution."
	local_pkginfo["template_path"] = os.path.normpath(os.path.join(os.path.dirname(__file__), "templates"))

	hub.pkgtools.pyhelper.pypi_normalize_version(local_pkginfo)

	artifacts = [hub.pkgtools.ebuild.Artifact(url=artifact_url)]
	if "cargo" in local_pkginfo["inherit"] and not compat_ebuild:
		cargo_artifacts = await hub.pkgtools.rust.generate_crates_from_artifact(artifacts[0], "*/src/rust")
		local_pkginfo["crates"] = cargo_artifacts["crates"]
		artifacts = [*artifacts, *cargo_artifacts["crates_artifacts"]]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**local_pkginfo,
		artifacts=artifacts,
		template="pypi-compat-1.tmpl"
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	pypi_name = hub.pkgtools.pyhelper.pypi_normalize_name(pkginfo)
	json_dict = await hub.pkgtools.fetch.get_page(
		f"https://pypi.org/pypi/{pypi_name}/json", refresh_interval=pkginfo["refresh_interval"], is_json=True
	)
	do_compat_ebuild = "compat" in pkginfo and pkginfo["compat"]
	await add_ebuild(hub, json_dict, compat_ebuild=False, has_compat_ebuild=do_compat_ebuild, **pkginfo)
	if do_compat_ebuild:
		await add_ebuild(hub, json_dict, compat_ebuild=True, **pkginfo)


# vim: ts=4 sw=4 noet
