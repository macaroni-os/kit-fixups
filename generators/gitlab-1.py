#!/usr/bin/python3

# This generators uses python-gitlab and his default configuration file
# under $HOME/.python-gitlab.cfg where this file MUST contains the definition
# of the server used in autogen.yaml files.
#
# $# cat ~/.python-gitlab.cfg
# [global]
# ssl_verify = false
# timeout = 5
# default = gitlab.com
# [gitlab.com]
# url = https://gitlab.com/
# private_token = <YOUR-TOKEN>
# api_version = 4
#
# The YAML syntax is pretty similar to github generator with the additional
# definition of the server to use.
#
# Example of YAML autogen:
#
# solarus:
#  generator: gitlab-1
#  packages:
#    - solarus:
#         gitlab:
#         user: solarus-games
#         repo: solarus
#         server: "gitlab.com"
#         query: tags
#
# Additional options.
# - query_parameters: through this param could be defined additional dictionary
#                     with query params to use on retrieve tags or releases.
#                     For example:
#                     query_parameters:
#                       per_page: 200
# - sources_format: Define the format of the sources to use. Default is .tar.bz2.
#                   This field is used on releases to retrieve the source url by format.
#
# TODO:
# - for binaries packages could be good to uses the assets.links with the different packages
#   per arch.
#   Example:
#     { 'links' : [
#        {
#            'direct_asset_url': 'https://gitlab.com/gitlab-org/gitlab-runner/-/releases/v16.8.0/downloads/binaries/gitlab-runner-linux-386',
#            'id': 3667461,
#            'link_type': 'other',
#            'name': 'binary: Linux 386',
#            'url': 'https://gitlab-runner-downloads.s3.amazonaws.com/v16.8.0/binaries/gitlab-runner-linux-386'
#        },
#        {
#            'direct_asset_url': 'https://gitlab.com/gitlab-org/gitlab-runner/-/releases/v16.8.0/downloads/binaries/gitlab-runner-linux-amd64-fips',
#            'id': 3667460,
#            'link_type': 'other',
#            'name': 'binary: Linux amd64-fips',
#            'url': 'https://gitlab-runner-downloads.s3.amazonaws.com/v16.8.0/binaries/gitlab-runner-linux-amd64-fips'
#        },
#        {
#            'direct_asset_url': 'https://gitlab.com/gitlab-org/gitlab-runner/-/releases/v16.8.0/downloads/binaries/gitlab-runner-linux-amd64',
#            'id': 3667459,
#            'link_type': 'other',
#            'name': 'binary: Linux amd64',
#            'url': 'https://gitlab-runner-downloads.s3.amazonaws.com/v16.8.0/binaries/gitlab-runner-linux-amd64'
#        }],
#    }
#

import gitlab

def get_key(name, pkginfo):
	"""
	This function looks first in gitlab block, and then in the main block for a specific key.

	We use this for things that we initially designed to be in the main block but make a lot
	more sense being in the gitlab block.
	"""
	if name in pkginfo["gitlab"]:
		return pkginfo["gitlab"][name]
	elif name in pkginfo:
		return pkginfo[name]
	else:
		return None


def create_transform(transform_data):
	def transform_lambda(tag):
		for trans_dict in transform_data:
			if "kind" not in trans_dict:
				raise ValueError("Please specify 'kind' for gitlab transform: element.")
			kind = trans_dict['kind']
			if kind == "string":
				match = trans_dict['match']
				replace = trans_dict['replace']
				tag = tag.replace(match, replace)
			else:
				raise ValueError(f"Unknown 'kind' for github transform: {kind}")
		return tag
	return transform_lambda


async def final_generate(project, hub, **pkginfo):
	if "extensions" in pkginfo:
		if "golang" in pkginfo["extensions"]:
			await hub.pkgtools.golang.add_gosum_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts'][0])
		if "rust" in pkginfo["extensions"]:
			await hub.pkgtools.rust.add_crates_bundle(hub, pkginfo, src_artifact=pkginfo['artifacts'][0])

	if "description" not in pkginfo:
		pkginfo["description"] = project.description

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# Parse releases of the project
async def release_gen(project, hub, extra_args, **pkginfo):
	qparams = {
		"per_page": 100,
	}

	if "query_parameters" in pkginfo["gitlab"]:
		qparams = pkginfo["gitlab"]["query_parameters"]

	releases = project.releases.list(query_parameters=qparams)

	# NOTE: the releases by default are returned in desc order

	found_version = None

	for release in releases:
		if "matcher" in extra_args:

			match = extra_args["matcher"].match(
				release["name"],
				select=pkginfo["gitlab"]["select"] if "select" in pkginfo["gitlab"] else None,
				filter=pkginfo["gitlab"]["filter"] if "filter" in pkginfo["gitlab"] else None
			)

			if match:
				found_version = release
				break

		else:
			# Get the first
			found_version = release
			break

	if found_version is not None:

		gitlab_user = pkginfo["gitlab_user"]
		gitlab_repo = pkginfo["gitlab_repo"]
		gitlab_server = pkginfo["gitlab_server"]

		# TODO: The version parsing must be reviewed to support filters.
		release_version = found_version.name
		if release_version.startswith("v"):
			version = found_version.name[1:]
		else:
			version = found_version.name

		sha = found_version.commit["id"]

		assets = found_version.assets

		gitlab_sources_format = pkginfo["sources_format"] if "sources_format" in pkginfo else "tar.bz2"

		sources = None
		for u in assets["sources"]:
			if u["format"] == gitlab_sources_format:
				sources = u["url"]
				break

		if sources is None:
			raise KeyError(
				f"{pkginfo['cat']}/{pkginfo['name']} No sources found with format {gitlab_sources_format}."
			)

		return {
			"version": version,
			"artifacts": [
				hub.pkgtools.ebuild.Artifact(
					url=sources, final_name=f'{gitlab_repo}-{version}.{gitlab_sources_format}')],
			"sha": sha,
			"tag": found_version.tag_name,
			"release": release_version,
		}

	else:
		return None

async def tag_gen(project, hub, extra_args, **pkginfo):

	qparams = {
		"per_page": 100,
	}

	if "query_parameters" in pkginfo["gitlab"]:
		qparams = pkginfo["gitlab"]["query_parameters"]
	
	tags = project.tags.list(query_parameters=qparams)

	# NOTE: the tags by default are returned in desc order

	found_version = None

	for tag in tags:
		if "matcher" in extra_args:

			match = extra_args["matcher"].match(
				tag["name"],
				select=pkginfo["gitlab"]["select"] if "select" in pkginfo["gitlab"] else None,
				filter=pkginfo["gitlab"]["filter"] if "filter" in pkginfo["gitlab"] else None
			)

			if match:
				found_version = tag
				break

		else:
			# Get the first
			found_version = tag
			break
	
	if found_version is not None:

		gitlab_user = pkginfo["gitlab_user"]
		gitlab_repo = pkginfo["gitlab_repo"]
		gitlab_server = pkginfo["gitlab_server"]
		project_id = project.id
		sha = found_version.target

		# TODO: The version parsing must be reviewed to support filters.
		tag_version = found_version.name
		if tag_version.startswith("v"):
			version = found_version.name[1:]
		else:
			version = found_version.name

		# Alternative way
		# url = f"https://{gitlab_server}/{gitlab_user}/{gitlab_rep}/-/archive/{tag_version}/{gitlab_repo}-{tag_version}.tar.bz2"
		url = f"https://{gitlab_server}/api/v4/projects/{project_id}/repository/archive.tar.bz2?sha={sha}"
		return {
			"version": version,
			"artifacts": [hub.pkgtools.ebuild.Artifact(
					url=url, final_name=f'{gitlab_repo}-{version}-{sha[:7]}.tar.bz2')],
			"sha": sha,
			"tag": tag_version,
		}

	else:
		return None

async def generate(hub, **pkginfo):
	# migrate keys inside "gitlab:" element to "gitlab_foo":
	if "gitlab" not in pkginfo:
		pkginfo["gitlab"] = {}
	for key in ["user", "repo", "server"]:
		if f"gitlab_{key}" not in pkginfo:
			if "gitlab" in pkginfo and key in pkginfo["gitlab"]:
				pkginfo[f"gitlab_{key}"] = pkginfo["gitlab"][key]
			else:
				pkginfo[f"gitlab_{key}"] = pkginfo["name"]

	# promote "match" and "select" in pkginfo into github element, so we support both inside and outside
	# this element for these keys:

	for key in ["match", "select"]:
		if key in pkginfo:
			if "gitlab" in pkginfo and key in pkginfo["gitlab"]:
				raise ValueError(f"{key} defined in both main YAML block and gitlab block -- chose one.")
			pkginfo["gitlab"][key] = pkginfo[key]
			del pkginfo[key]

	query = pkginfo["gitlab"]["query"]
	if query not in ["releases", "tags", "snapshot"]:
		raise KeyError(
			f"{pkginfo['cat']}/{pkginfo['name']} should specify GitLab query type of 'releases', 'tags' or 'snapshot'."
		)

	gitlab_user = pkginfo["gitlab_user"]
	gitlab_repo = pkginfo["gitlab_repo"]
	gitlab_server = pkginfo["gitlab_server"]

	# Create gitlab api client. We use default python-gitlab authorization file. ~/.python-gitlab.cfg
	# We use gitlab_server to identify the server to use.
	gl = gitlab.Gitlab.from_config(gitlab_server)

	# Authenticate
	gl.auth()

	# This special snapshot method short-circuits the regular logic:
	#if query == "snapshot":
	#	snapshot = pkginfo["github"]["snapshot"]
	#	url = f"https://github.com/{github_user}/{github_repo}/archive/{snapshot}.zip"
	#	if "version" not in pkginfo:
	#		raise ValueError("Please specify a version when using github-1 snapshot feature.")
	#	pkginfo["artifacts"] = [hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{pkginfo['name']}-{pkginfo['version']}-{snapshot[:7]}.zip")]
	#	await final_generate(hub, **pkginfo)
	#	return

	if "homepage" not in pkginfo:
		pkginfo["homepage"] = f"https://{gitlab_server}/{gitlab_user}/{gitlab_repo}"

	extra_args = {}
	if "select" in pkginfo and "match" in pkginfo["gitlab"]:
		raise ValueError("Please use either 'select' or 'match' but not both.")

	if "include" in pkginfo["gitlab"]:
		extra_args["include"] = pkginfo["gitlab"]["include"]

	# Extra args handling:

	for arg in ["version"]:
		extra_args[arg] = pkginfo[arg] if arg in pkginfo else None
	if extra_args["version"] == "latest":
		del extra_args["version"]

	if "transform" in pkginfo["gitlab"]:
		extra_args["transform"] = create_transform(pkginfo["gitlab"]["transform"])

	# Retrieve project data
	project = gl.projects.get(f"{gitlab_user}/{gitlab_repo}")


	if "match" in pkginfo["gitlab"]:
		# explicit match from YAML:
		extra_args["matcher"] = hub.pkgtools.github.RegexMatcher(regex=pkginfo["gitlab"]["match"])
	elif "select" in extra_args:
		# If a user specifies "select", they probably want the classic grabby matcher and are using "select" to filter undesireables:
		extra_args["matcher"] = hub.pkgtools.github.RegexMatcher(regex=hub.pkgtools.github.VersionMatch.GRABBY)

	if query == "tags":

		gitlab_result = await tag_gen(project, hub, extra_args, **pkginfo)

	else:

		gitlab_result = await release_gen(project, hub, extra_args, **pkginfo)

	if gitlab_result is None:
		raise KeyError(
			f"Unable to find suitable Gitlab release/tag for {pkginfo['cat']}/{pkginfo['name']}."
		)

	pkginfo.update(gitlab_result)

	await final_generate(project, hub, **pkginfo)

# vim: ts=4 sw=4 noet
