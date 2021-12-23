#!/usr/bin/env python3
from datetime import datetime, timedelta
from packaging import version


async def generate(hub, **pkginfo):
	github_user = "sainnhe"
	github_repo = "gruvbox-material-gtk"

	commits_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/commits",
		is_json=True,
		refresh_interval=timedelta(days=15),
	)

	target_commit = commits_data[0]

	commit_date = datetime.strptime(target_commit["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	commit_hash = target_commit["sha"]

	version = commit_date.strftime("%Y%m%d")

	source_url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_hash}.tar.gz"
	source_name = f"{pkginfo['name']}-{commit_hash}.tar.gz"

	source_artifact = hub.pkgtools.ebuild.Artifact(url=source_url, final_name=source_name)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_repo=github_repo,
		commit_hash=commit_hash,
		artifacts=[source_artifact],
	)

	ebuild.push()
