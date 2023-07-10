#!/usr/bin/env python3
import metatools.cmd
import os


async def generate(hub, **pkginfo):
	github_user = "funtoo"
	github_repo = "qtile"
	tag = pkginfo["version"] = "0.22.1.20230709"
	final_name = f'qtile-{tag}.tar.gz'
	my_archive, metadata = hub.Archive.find_by_name(final_name)

	if my_archive is None:
		my_archive = hub.Archive(final_name)
		await my_archive.create_work_path()
		dir_and_cmds = [
			(my_archive.work_path, f"git clone --depth 1 --branch {tag} https://github.com/{github_user}/{github_repo}.git qtile"),
			(os.path.join(my_archive.work_path, "qtile"), f"python3 setup.py sdist"),
		]
		for chdir, cmd in dir_and_cmds:
			retval = await metatools.cmd.run_bg(f"( cd {chdir} && {cmd} )")
			if retval != 0:
				raise hub.pkgtools.ebuild.BreezyError(f"Unable to run: {cmd}")
		await my_archive.store_by_name(existing=os.path.join(my_archive.work_path, f"qtile/dist/qtile-{tag}.tar.gz"))

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[my_archive]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
