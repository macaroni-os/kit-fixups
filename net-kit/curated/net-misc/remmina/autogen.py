#!/usr/bin/env python3

from packaging import version


async def generate(hub, **pkginfo):
	gitlab_user = gitlab_repo = "Remmina"
	project_path = f"{gitlab_user}%2F{gitlab_repo}"

	release_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.com/api/v4/projects/{project_path}/releases",
		is_json=True,
	)

	try:
		latest_release = max(
			(release for release in release_data if not release["upcoming_release"]),
			key=lambda release: version.parse(release["tag_name"]),
		)
	except ValueError:
		raise hub.pkgtools.ebuild.BreezyError(
			f"Can't find suitable release of {gitlab_repo}"
		)

	tag_name = latest_release["tag_name"]
	latest_version = tag_name.lstrip("v")

	source_name = f"{gitlab_repo}-{tag_name}.tar.gz"
	source_asset = next(
		asset
		for asset in latest_release["assets"]["sources"]
		if asset["url"].endswith(source_name)
	)

	source_url = source_asset["url"]
	source_name = f"{gitlab_repo}-{latest_version}.tar.gz"

	source_artifact = hub.pkgtools.ebuild.Artifact(
		url=source_url, final_name=source_name
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		gitlab_user=gitlab_user,
		gitlab_repo=gitlab_repo,
		artifacts=[source_artifact],
	)
	ebuild.push()

