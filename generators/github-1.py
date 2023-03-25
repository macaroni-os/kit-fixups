#!/usr/bin/python3

def get_key(name, pkginfo):
	"""
	This function looks first in github block, and then in the main block for a specific key.

	We use this for things that we initially designed to be in the main block but make a lot
	more sense being in the github block.
	"""
	if name in pkginfo["github"]:
		return pkginfo["github"][name]
	elif name in pkginfo:
		return pkginfo[name]
	else:
		return None


def create_transform(transform_data):
	def transform_lambda(tag):
		for trans_dict in transform_data:
			if "kind" not in trans_dict:
				raise ValueError("Please specify 'kind' for github transform: element.")
			kind = trans_dict['kind']
			if kind == "string":
				match = trans_dict['match']
				replace = trans_dict['replace']
				tag = tag.replace(match, replace)
			else:
				raise ValueError(f"Unknown 'kind' for github transform: {kind}")
		return tag
	return transform_lambda


async def generate(hub, **pkginfo):
	# migrate keys inside "github:" element to "github_foo":
	if "github" not in pkginfo:
		pkginfo["github"] = {}
	for key in ["user", "repo"]:
		if f"github_{key}" not in pkginfo:
			if "github" in pkginfo and key in pkginfo["github"]:
				pkginfo[f"github_{key}"] = pkginfo["github"][key]
			else:
				pkginfo[f"github_{key}"] = pkginfo["name"]

	# promote "match" and "select" in pkginfo into github element, so we support both inside and outside
	# this element for these keys:

	for key in ["match", "select"]:
		if key in pkginfo:
			if "github" in pkginfo and key in pkginfo["github"]:
				raise ValueError(f"{key} defined in both main YAML block and github block -- chose one.")
			pkginfo["github"][key] = pkginfo[key]
			del pkginfo[key]

	query = pkginfo["github"]["query"]
	if query not in ["releases", "tags"]:
		raise KeyError(
			f"{pkginfo['cat']}/{pkginfo['name']} should specify GitHub query type of 'releases' or 'tags'."
		)

	github_user = pkginfo["github_user"]
	github_repo = pkginfo["github_repo"]

	if "homepage" not in pkginfo:
		pkginfo["homepage"] = f"https://github.com/{github_user}/{github_repo}"

	extra_args = {}
	if "select" in pkginfo and "match" in pkginfo["github"]:
		raise ValueError("Please use either 'select' or 'match' but not both.")

	# Extra args handling:

	for arg in ["version"]:
		extra_args[arg] = pkginfo[arg] if arg in pkginfo else None
	if extra_args["version"] == "latest":
		del extra_args["version"]

	if "transform" in pkginfo["github"]:
		extra_args["transform"] = create_transform(pkginfo["github"]["transform"])

	# GitHub args handling:

	for gh_arg in ["select"]:
		if gh_arg in pkginfo["github"]:
			extra_args[gh_arg] = pkginfo["github"][gh_arg]

	if "match" in pkginfo["github"]:
		# explicit match from YAML:
		extra_args["matcher"] = hub.pkgtools.github.RegexMatcher(regex=pkginfo["github"]["match"])
	elif "select" in extra_args:
		# If a user specifies "select", they probably want the classic grabby matcher and are using "select" to filter undesireables:
		extra_args["matcher"] = hub.pkgtools.github.RegexMatcher(regex=hub.pkgtools.github.VersionMatch.GRABBY)

	if query == "tags":
		github_result = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo, **extra_args)
	else:
		assets = get_key("assets", pkginfo)
		tarball = get_key("tarball", pkginfo)
		if assets and tarball:
			raise KeyError("Please specify assets: or tarball: but not both.")
		if assets:
			github_result = await hub.pkgtools.github.release_gen(
				hub,
				github_user,
				github_repo,
				assets=assets,
				**extra_args
			)
		else:
			github_result = await hub.pkgtools.github.release_gen(
				hub,
				github_user,
				github_repo,
				tarball=tarball,   # This intentionally may be None if no tarball is found. That's OK.
				**extra_args
			)

	if github_result is None:
		raise KeyError(
			f"Unable to find suitable GitHub release/tag for {pkginfo['cat']}/{pkginfo['name']}."
		)

	pkginfo.update(github_result)

	if "extensions" in pkginfo:
		if "golang" in pkginfo["extensions"]:
			await hub.pkgtools.golang.add_gosum_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts'][0])
		if "rust" in pkginfo["extensions"]:
			await hub.pkgtools.rust.add_crates_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts'][0])

	if "description" not in pkginfo:
		repo_metadata = await hub.pkgtools.fetch.get_page(
			f"https://api.github.com/repos/{github_user}/{github_repo}", is_json=True
		)
		pkginfo["description"] = repo_metadata["description"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
