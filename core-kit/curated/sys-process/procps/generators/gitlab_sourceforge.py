#!/usr/bin/env python3

from packaging import version


async def generate(lab, **pkginfo):
	gitlab_user = pkginfo.get('gitlab_user')
	gitlab_repo = pkginfo.get('gitlab_repo') or pkginfo.get('name')
	project_path = f"{gitlab_user}%2F{gitlab_repo}"

	tag_data = await lab.pkgtools.fetch.get_page(
		f"https://gitlab.com/api/v4/projects/{project_path}/repository/tags",
		is_json=True,
	)

	try:
		latest_tag = max(
			(tag for tag in tag_data),
			key=lambda tag: version.parse(tag["name"]),
		)
	except ValueError:
		raise lab.pkgtools.ebuild.BreezyError(
			f"Can't find suitable tag of {gitlab_repo}"
		)

	tag_name = latest_tag["name"]
	latest_version = tag_name.lstrip("v")

	source_name = f"{gitlab_repo}-{latest_version}.tar.xz"

	source_url = f"https://downloads.sourceforge.net/project/{gitlab_user}/Production/{gitlab_user}-{latest_version}.tar.xz"

	source_artifact = lab.pkgtools.ebuild.Artifact(url=source_url)

	ebuild = lab.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		artifacts=[source_artifact],
	)
	ebuild.push()

