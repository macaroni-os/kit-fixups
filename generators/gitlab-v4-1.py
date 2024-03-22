#!/usr/bin/env python3
from funtoo.pkgtools.github import iter_tag_versions, TagRegexMatcher
from packaging.version import Version
from metatools.generator.transform import create_transform

async def generate(hub, **pkginfo):
	user = pkginfo["name"]
	repo = pkginfo["name"]
	server = "https://gitlab.com"
	transform = match = select = None

	if "gitlab_user" in pkginfo:
		user = pkginfo["gitlab_user"]
	elif "gitlab" in pkginfo and "user" in pkginfo["gitlab"]:
		user = pkginfo["gitlab"]["user"]

	if "gitlab_repo" in pkginfo:
		repo = pkginfo["gitlab_repo"]
	elif "gitlab" in pkginfo and "repo" in pkginfo["gitlab"]:
		repo = pkginfo["gitlab"]["repo"]

	if "gitlab_server" in pkginfo:
		server = pkginfo["gitlab_server"]
	elif "gitlab" in pkginfo and "server" in pkginfo["gitlab"]:
		server = pkginfo["gitlab"]["server"]

	if "transform" in pkginfo["gitlab"]:
		transform = create_transform(pkginfo["gitlab"]["transform"])

	if "match" in pkginfo["gitlab"]:
		match = create_transform(pkginfo["gitlab"]["match"])
	elif "select" in pkginfo["gitlab"]:
		select = create_transform(pkginfo["gitlab"]["match"])

	query = pkginfo["gitlab"]["query"]
	if query not in ["releases", "tags", "snapshot"]:
		raise KeyError(
			f"{pkginfo['cat']}/{pkginfo['name']} should specify GitLab query type of 'releases', 'tags' or 'snapshot'."
		)

	if query == "tags":
		project_path = f"{user}%2F{repo}"
		info_url = f"https://{server}/api/v4/projects/{project_path}/repository/tags"
	elif query == "releases":
		if "project_id" not in pkginfo["gitlab"]:
			raise KeyError("To query releases, we require a project ID defined in gitlab/project_id")
		project_id = pkginfo["gitlab"]["project_id"]
		info_url = f"https://{server}/api/v4/projects/{project_id}/releases"
	

	tags_dict = await hub.pkgtools.fetch.get_page(
		info_url, is_json=True
	)

	# TODO: implement filter=

	versions_and_tag_elements = []
	matcher = TagRegexMatcher()
	async for v_tagel in iter_tag_versions(tags_dict, select=select, filter=None, matcher=matcher, transform=transform, version=None):
		versions_and_tag_elements.append(v_tagel)
	version, tag_elements = max(versions_and_tag_elements, key=lambda v: matcher.sortable(v[0]))

	#versions = [Version(tag["name"]) for tag in tags_dict if not tag["name"].upper().isupper()]

	artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive/{version}/{repo}-{version}.tar.bz2"
	)

	if "extensions" in pkginfo:
		if "golang" in pkginfo["extensions"]:
			await hub.pkgtools.golang.add_gosum_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts'][0])
		if "rust" in pkginfo["extensions"]:
			await hub.pkgtools.rust.add_crates_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts'][0])

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
