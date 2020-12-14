#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	changelog_data = await hub.pkgtools.fetch.get_page(
		"https://launchercontent.mojang.com/launcherPatchNotes_v2.json", is_json=True
	)
	version = changelog_data["entries"][0]["versions"]["linux"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://launcher.mojang.com/download/linux/x86_64/minecraft-launcher_{version}.tar.gz"
			),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
