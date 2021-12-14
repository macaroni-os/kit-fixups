#!/usr/bin/python3

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}


async def generate(hub, **pkginfo):
	assert "python_compat" in pkginfo, f"python_compat is not defined in {pkginfo}"

	pypi_name = hub.pkgtools.pyhelper.pypi_normalize_name(pkginfo)

	json_dict = await hub.pkgtools.fetch.get_page(
		f"https://pypi.org/pypi/{pypi_name}/json", refresh_interval=pkginfo["refresh_interval"], is_json=True
	)

	if "version" not in pkginfo or pkginfo["version"] == "latest":
		# This will grab the latest version:
		pkginfo["version"] = json_dict["info"]["version"]

	artifact_url = None
	for artifact in json_dict["releases"][pkginfo["version"]]:
		if artifact["packagetype"] == "sdist":
			artifact_url = artifact["url"]
			break
	assert (
		artifact_url is not None
	), f"Artifact URL could not be found in {pkginfo}. This can indicate a PyPi package without a 'source' distribution."

	hub.pkgtools.pyhelper.pypi_normalize_version(pkginfo)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[hub.pkgtools.ebuild.Artifact(url=artifact_url)])
	ebuild.push()


# vim: ts=4 sw=4 noet
