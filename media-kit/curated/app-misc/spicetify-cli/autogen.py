#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "spicetify"
	repo = pkginfo["name"]

	release_data = await hub.pkgtools.github.release_gen(hub, user, repo)
	(src_artifact,) = release_data["artifacts"]

	golang_artifacts = await hub.pkgtools.golang.generate_gosum_from_artifact(
		src_artifact
	)

	release_data["artifacts"].extend(golang_artifacts["gosum_artifacts"])
	pkginfo.update(release_data)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=user,
		github_repo=repo,
		gosum=golang_artifacts["gosum"],
	)
	ebuild.push()

