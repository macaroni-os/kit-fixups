#!/usr/bin/python3

import os

GLOBAL_DEFAULTS = {"cat": "virtual", "refresh_interval": None, "python_compat": "python3+"}


async def generate(hub, **pkginfo):
	hub.pkgtools.pyhelper.expand_pydeps(pkginfo)
	pkginfo["template_path"] = os.path.normpath(os.path.join(os.path.dirname(__file__), "templates"))
	pkginfo["template"] = "python-virtual-1.tmpl"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
