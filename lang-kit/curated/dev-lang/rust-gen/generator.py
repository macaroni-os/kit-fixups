#!/usr/bin/env python3

from packaging import version
import glob
import os


def build_indented_string(parts, indent_level=1):
	"""
	Build a string from a list of lists, increasing indentation for every level.

	:param parts: list to flatten and join
	:type parts: list
	:param indent_level: current level of indentation
	:type indent_level: int
	:return: a properly indented string
	:rtype: str
	"""
	res = []
	indentation = "\t" * indent_level

	for part in parts:
		if type(part) == list:
			res.append(build_indented_string(part, indent_level + 1))
		else:
			res.append(indentation + part)

	return "\n".join(res)


def get_release(release_data):
	"""
	Find the latest release based on tag name.

	:param release_data: release data from github api
	:type release_data: list
	:return: latest release
	:rtype: dict
	"""
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()


async def get_latest_version(hub, user, repo):
	"""
	Fetch latest version for a GitHub repo.

	:param hub: metatools hub
	:type hub: Hub
	:param user: github user
	:type user: str
	:param repo: github repo
	:type repo: str
	:return: latest version
	:rtype str
	"""
	release_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases",
													 is_json=True)

	latest_release = get_release(release_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find suitable release of {repo}")

	return latest_release["tag_name"]


def get_rust_artifact(hub, name, pkginfo, chost=None):
	"""
	Get Rust component artifact

	:param hub: metatools hub
	:type hub: Hub
	:param name: name of rust component
	:type name: str
	:param pkginfo: current package info
	:type pkginfo: dict
	:param chost: chost to generate artifact for
	:type chost: str
	:return: artifact for rust component
	:rtype Artifact
	"""
	target_filename = "-".join([part for part in [name, pkginfo["version"], chost] if part is not None])
	target_url = f"https://static.rust-lang.org/dist/{target_filename}.tar.xz"

	return hub.pkgtools.ebuild.Artifact(url=target_url)


async def generate_rust_arch_data(hub, pkginfo):
	"""
	Generate arch-specific information for current Rust package: source artifacts, per-arch source URIs,
	and a utility to match CHOST to Rust ABI.

	:param hub: metatools hub
	:type hub: Hub
	:param pkginfo: current package info
	:type pkginfo: dict
	:return: artifacts, src uris and abi getter for current package
	:rtype dict
	"""
	target_arches = pkginfo["target_arches"]

	artifacts = []
	src_uri_template = []
	abi_getter_cases = []

	for target_arch, chosts in target_arches.items():
		src_uri_template.append(f"{target_arch}? ( ")

		curr_uris = []
		for chost_data in chosts:
			curr_artifact = get_rust_artifact(hub, "rust", pkginfo, chost_data["chost"])

			curr_uris.append(curr_artifact.src_uri)
			artifacts.append(curr_artifact)

			abi_getter_cases.append(f"{chost_data['pattern']}) echo {chost_data['chost']};;")

		src_uri_template.append(curr_uris)
		src_uri_template.append(")")

	extra_components = pkginfo.get("extra_components", {})
	extra_component_data = {}

	for component_name, component_data in extra_components.items():
		src_uri_template.append(f"{component_name}? (")

		component_artifact = get_rust_artifact(hub, component_data["name"], pkginfo, component_data.get("chost", None))
		artifacts.append(component_artifact)

		await component_artifact.fetch()
		component_artifact.extract()

		component_dir = glob.glob(os.path.join(component_artifact.extract_path, "*"))[0]
		extracted_name = os.path.basename(component_dir)

		with open(os.path.join(component_dir, "components"), "r") as components_file:
			included_components = [line.strip() for line in components_file.readlines()]

		component_artifact.cleanup()

		extra_component_data[component_name] = {
			"included_components": included_components,			
			"extracted_name": extracted_name,
		}

		src_uri_template.append([component_artifact.src_uri])
		src_uri_template.append(f")")

	abi_getter_fn = [
		"local CTARGET=${1:-${CHOST}}",
		"case ${CTARGET%%*-} in",
		abi_getter_cases,
		"esac"
	]

	return dict(
		artifacts=artifacts,
		src_uri_template=build_indented_string(src_uri_template),
		abi_getter_fn=build_indented_string(abi_getter_fn),
		extra_component_data=extra_component_data,
	)


async def preprocess_packages(hub, pkginfo_list):
	"""
	Populate pkginfo with all necessary information to generate a Rust ebuild.

	:param hub: metatools hub
	:type hub: Hub
	:param pkginfo_list: a list of pkginfo dicts
	:type pkginfo_list: list
	"""
	user = "rust-lang"
	repo = "rust"
	latest_version = await get_latest_version(hub, user, repo)

	for pkginfo in pkginfo_list:
		if "version" in pkginfo:
			if pkginfo["version"] == "latest":
				pkginfo["version"] = latest_version
		else:
			pkginfo["version"] = latest_version
		arch_data = await generate_rust_arch_data(hub, pkginfo)
		pkginfo.update(arch_data)

		stdlib_src_artifact = get_rust_artifact(hub, "rust-src", pkginfo)

		pkginfo["artifacts"].append(stdlib_src_artifact)
		pkginfo["stdlib_src_uri"] = stdlib_src_artifact.src_uri

		yield pkginfo


async def generate(hub, **pkginfo):
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo
	)

	ebuild.push()

	# Generate a virtual/rust ebuild for the current version
	virtual_ebuild = hub.pkgtools.ebuild.BreezyBuild(
		cat="virtual",
		name="rust",
		version=pkginfo["version"],
		template="rust-virtual.tmpl",
		template_path=pkginfo["template_path"],
	)

	virtual_ebuild.push()

# vim: ts=4 sw=4 noet
