#!/usr/bin/env python3

import os
import toml


async def get_unidic_artifact(hub):
	info_url = "https://formulae.brew.sh/api/formula/mecab-unidic.json"
	info = await hub.pkgtools.fetch.get_page(info_url, is_json=True)

	return hub.pkgtools.ebuild.Artifact(url=info["urls"]["stable"]["url"])


async def generate(hub, **pkginfo):
	github_user = github_repo = "meilisearch"

	pkginfo["github_user"] = github_user
	pkginfo["github_repo"] = github_repo

	release_info = await hub.pkgtools.github.release_gen(hub, github_user, github_repo)
	pkginfo.update(release_info)

	src_artifact = pkginfo["artifacts"][0]
	pkginfo["artifacts"] = {
		"src": src_artifact,
	}

	await src_artifact.ensure_fetched()
	src_artifact.extract()

	src_path = os.path.join(
		src_artifact.extract_path, f"{github_user}-{github_repo}-{pkginfo['sha'][:7]}"
	)

	cargo_lock_path = os.path.join(src_path, "Cargo.lock")
	await hub.pkgtools.rust.add_crates_bundle(
		hub, pkginfo, cargo_lock_path=cargo_lock_path
	)

	meili_package_path = os.path.join(src_path, "meilisearch", "Cargo.toml")
	with open(meili_package_path, "r") as meili_package_file:
		meili_package_data = toml.load(meili_package_file)

	dashboard_metadata = meili_package_data["package"]["metadata"]["mini-dashboard"]

	dashboard_url = pkginfo["dashboard_url"] = dashboard_metadata["assets-url"]
	dashboard_sha = dashboard_metadata["sha1"]

	pkginfo["artifacts"]["dashboard"] = hub.pkgtools.ebuild.Artifact(
		url=dashboard_url,
		final_name=f"{github_repo}-mini-dashboard-{dashboard_sha}.zip",
	)

	pkginfo["artifacts"]["unidic"] = await get_unidic_artifact(hub)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()
