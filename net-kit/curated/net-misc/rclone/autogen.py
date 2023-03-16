#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	github_user = "rclone"
	github_repo = "rclone"
	json_dict = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True)
	tag = json_dict[0]["tag_name"]
	pkginfo["version"] = version = tag.lstrip("v")
	pkginfo["artifacts"] = { "main" :
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{github_user}/{github_repo}/releases/download/{tag}/{github_repo}-{tag}.tar.gz"
			)
	}
	gosum_raw = await hub.pkgtools.fetch.get_page(f"https://github.com/{github_user}/{github_repo}/raw/v{version}/go.sum")
	await hub.pkgtools.golang.add_gosum_archive(hub, gosum_raw, pkginfo)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()


# vim: ts=4 sw=4 noet
