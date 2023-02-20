#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	version = pkginfo.get("version", None)

	release_info = await hub.pkgtools.github.release_gen(
		hub,
		pkginfo["github"]["user"],
		pkginfo["github"]["repo"],
		tarball=pkginfo["tarball"],
		version=version,
	)

	if pkginfo["name"] == "kitty" and pkginfo.get("needs_golang", False):
		(source_artifact,) = release_info["artifacts"]

		golang_deps = await hub.pkgtools.golang.generate_gosum_from_artifact(
			source_artifact
		)

		release_info["artifacts"].extend(golang_deps["gosum_artifacts"])
		release_info["gosum"] = golang_deps["gosum"]

	pkginfo.update(release_info)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
	)
	ebuild.push()
