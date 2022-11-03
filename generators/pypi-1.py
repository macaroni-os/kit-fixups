#!/usr/bin/python3

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}


async def generate(hub, **pkginfo):
	assert "python_compat" in pkginfo, f"python_compat is not defined in {pkginfo}"

	pypi_name = hub.pkgtools.pyhelper.pypi_normalize_name(pkginfo)

	json_dict = await hub.pkgtools.fetch.get_page(
		f"https://pypi.org/pypi/{pypi_name}/json", refresh_interval=pkginfo["refresh_interval"], is_json=True
	)
	if "version" not in json_dict:
		json_dict["version"] = "latest"
	artifact_url = hub.pkgtools.pyhelper.pypi_get_artifact_url(pkginfo, json_dict, strict=False)
	hub.pkgtools.pyhelper.pypi_normalize_version(pkginfo)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[hub.pkgtools.ebuild.Artifact(url=artifact_url)])
	ebuild.push()


# vim: ts=4 sw=4 noet
