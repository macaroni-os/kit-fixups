#!/usr/bin/env python3
import os

async def generate_archive_from_git(hub, pkginfo):
	url = f"https://gitlab.freedesktop.org/{pkginfo['gitlab']['user']}/{pkginfo['name']}.git"
	final_name = f"{pkginfo['name']}-{pkginfo['version']}-with-submodules.tar.xz"
	my_archive, metadata = hub.Archive.find_by_name(final_name)
	if my_archive is None:
		my_archive = hub.Archive(final_name)
		await my_archive.initialize()
		cmd = f"( cd {my_archive.top_path}; git clone --depth 1 --branch {pkginfo['tag_name']} --recursive {url} {pkginfo['name']}-{pkginfo['tag_name']})"
		hub.pkgtools.model.log.info(cmd)
		retval = os.system(cmd)
		if retval != 0:
			raise hub.pkgtools.ebuild.BreezyError("Unable to git clone repository.")
		await my_archive.store_by_name()
	return my_archive


async def generate(hub, **pkginfo):
	user = pkginfo['gitlab']['user']
	repo = pkginfo["name"]
	releases_url = f"{pkginfo['gitlab']['url']}/api/v4/projects/{pkginfo['gitlab']['project_id']}/releases"
	releases = await hub.pkgtools.fetch.get_page(releases_url, is_json=True)
	prefix = pkginfo['gitlab']['prefix']
	if "version" not in pkginfo or pkginfo["version"] == "latest":
		for release in releases:
			if not release['tag_name'].startswith(prefix):
				continue
			if release["upcoming_release"]:
				continue
			pkginfo["version"] = release['tag_name'][len(prefix):]
			selected_release = release
			break
	else:
		for release in releases:
			if not release['tag_name'].startswith(prefix):
				continue
			version = release['tag_name'][len(prefix):]
			if version == pkginfo["version"]:
				selected_release = release
				break
	pkginfo['tag_name'] = selected_release['tag_name']
	if pkginfo['name'] in [ 'spice', 'spice-gtk' ]:
		artifact = await generate_archive_from_git(hub, pkginfo)
	else:
		source_url = None
		for source in release['assets']['sources']:
			if source['format'] == "tar.gz":
				source_url = source['url']
		artifact = hub.pkgtools.ebuild.Artifact(url=source_url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		gitlab_user=user,
		gitlab_repo=repo,
		artifacts=[artifact],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
