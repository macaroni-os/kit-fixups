#!/usr/bin/python3

import os

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}


async def generate(hub, **pkginfo):
	pkginfo["template_path"] = os.path.normpath(os.path.join(os.path.dirname(__file__), "templates"))
	pkginfo["template"] = "python-namespace-1.tmpl"
	if not pkginfo["name"].startswith("namespace-"):
		raise ValueError(f"Invalid package name: {pkginfo['name']} -- namespace packages must start with 'namespace'")
	pkginfo["namespace"] = "-".join(pkginfo["name"].split("-")[1:])  # remove the initial "namespace-" part
	pkginfo["description"] = f"Namespace declaration for {pkginfo['namespace']}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
