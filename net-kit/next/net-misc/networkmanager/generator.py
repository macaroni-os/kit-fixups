#!/usr/bin/env python3

from packaging.version import Version

async def generate(hub, **pkginfo):
	user = pkginfo["gitlab_user"]
	repo = pkginfo["gitlab_repo"] if "gitlab_repo" in pkginfo else pkginfo["name"]
	project_path = f"{user}%2F{repo}"
	tags_dict = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags", is_json=True
	)
	versions = [Version(tag["name"]) for tag in tags_dict if not tag["name"].upper().isupper() ]
	version = max(versions).public
	artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive/{version}/{repo}-{version}.tar.bz2"
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact],
	)
	ebuild.push()
