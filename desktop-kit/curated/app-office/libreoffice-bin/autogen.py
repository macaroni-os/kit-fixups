#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re


def get_lang_artifacts(hub, lang_url, lang_soup, lang_type):
	artifacts = {}
	for link in lang_soup.find_all("a"):
		href = link.get("href")
		if lang_type in href and href.endswith("tar.gz"):
			abbrv = href.split(".tar")[0].split("_")[-1]
			ver_match = re.search("([0-9.]+)", href)
			version = ver_match.groups()[0]
			if "en-US" in abbrv:
				abbrv = "en:en-US"
			elif "pa-IN" in abbrv:
				abbrv = "pa:pa-IN"
			elif "sa-IN" in abbrv:
				abbrv = "sa:sa-IN"
			artifacts[abbrv] = hub.pkgtools.ebuild.Artifact(url=lang_url + href)
			setattr(artifacts[abbrv], 'version', version)
	return artifacts


def gen_src_uri(pkginfo, my_artifacts_dict, cond_iuse=None):
	"""
	Given a dictionary mapping language IDs to helppack or langpack artifacts, update 'iuse' in
	pkginfo and also update 'src_uri' to contain a fully-formatted SRC_URI string to directly
	insert into the template.

	Input: a dictionary. Each dictionary element has a string language id key that points to the
	Artifact object represented by the ID (which was grabbed using BeautifulSoup.)

	Output: We will write directly into pkginfo, and not directly return anything. key 'src_uri'
	will contain the SRC_URI string (which will get appended to in successive calls), and 'iuse'
	will contain a set of IUSE variables to insert into the template.
	"""
	src_uri = ""
	if 'iuse' not in pkginfo:
		pkginfo['iuse'] = set()
	for lang, artifact in my_artifacts_dict.items():
		lang_first_part = lang.split(':')[0]
		iuse_lang = f'l10n_{lang_first_part}'
		pkginfo['iuse'].add(iuse_lang)
		if cond_iuse:
			src_uri += f'{iuse_lang}? ( {cond_iuse}? ( {artifact.src_uri} ) )\n'
		else:
			src_uri += f'{iuse_lang}? ( {artifact.src_uri} )\n'
	if "src_uri" not in pkginfo:
		pkginfo["src_uri"] = src_uri
	else:
		pkginfo["src_uri"] += src_uri


def gen_lang_keys(artifacts_dict, main_version):
	"""
	This method is used to generate the list of language codes at the top of the template. We have
	added a feature to optionally store the version of the langpack/helppack at the end of the string
	like "foo/7.5.2" if the langpack version differs from that in the ebuild. We will then have the
	bash code in the template grab this version if it exists. We need this for RPM extraction.

	The version hack described above can be disabled by setting main_version to None. Then we will
	not encode any extra version information for the packs.
	"""
	out = []
	for key in sorted(list(artifacts_dict.keys())):
		artifact = artifacts_dict[key]
		if main_version is not None and artifact.version != main_version:
			out.append(f'{key}/{artifact.version}')
		else:
			out.append(key)
	return " ".join(out)


async def add_l10n_ebuild(hub, ebuild_bin, version, **pkginfo):
	dl_url = f"https://downloadarchive.documentfoundation.org/libreoffice/old/{version}/rpm/x86_64/"
	dl_data = await hub.pkgtools.fetch.get_page(dl_url)
	dl_soup = BeautifulSoup(dl_data, "html.parser")

	artifacts = []
	langpack_artifacts = get_lang_artifacts(hub, dl_url, dl_soup, "langpack")
	helppack_artifacts = get_lang_artifacts(hub, dl_url, dl_soup, "helppack")

	# Add all artifacts, so we can pass to artifacts= for BreezyBuild so these are all fetched:
	artifacts += langpack_artifacts.values()
	artifacts += helppack_artifacts.values()

	gen_src_uri(pkginfo, langpack_artifacts)
	gen_src_uri(pkginfo, helppack_artifacts, cond_iuse="offlinehelp")

	# convert iuse from a set to a sorted list for jinja:
	pkginfo['iuse'] = ' '.join(sorted(list(pkginfo['iuse'])))
	
	# I added this for libreoffice-7.2.5.2. The lang/help packs have version 7.2.5. So I assumed the RPM-extracted
	# directory would also have the wrong version. But it has the right version. However, we may need this in the
	# future. To enable it, just set version_hack = version, which will cause the langpack version to be encoded
	# in the ebuild if it differs from ${PV}.

	version_hack = None

	pkginfo.update(
		template_path=ebuild_bin.template_path,
		name="libreoffice-l10n",
		version=version,
		languages=gen_lang_keys(langpack_artifacts, version_hack),
		languages_help=gen_lang_keys(helppack_artifacts, version_hack),
		artifacts=artifacts
	)
	ebuild_l10n = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild_l10n.push()

async def generate(hub, **pkginfo):
	html_url = f"https://www.libreoffice.org/download/download/"
	html_data = await hub.pkgtools.fetch.get_page(html_url)
	soup = BeautifulSoup(html_data, "html.parser")
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.endswith(".xz?idx=1"):
			version = href.split(".tar")[0].split("-")[1]
	dl_url = f"https://downloadarchive.documentfoundation.org/libreoffice/old/{version}/rpm/x86_64/"
	main_tarball_version = await hub.pkgtools.pages.iter_links(
		base_url=dl_url,
		match_fn=lambda x: re.match(f"LibreOffice_([0-9.]+)_Linux_x86-64_rpm.tar.gz", x),
		fixup_fn=lambda x: x.groups()[0],
		first_match=True
	)
	url = dl_url + f"LibreOffice_{main_tarball_version}_Linux_x86-64_rpm.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url)]
	ebuild_bin = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, artifacts=artifacts)
	ebuild_bin.push()
	await add_l10n_ebuild(hub, ebuild_bin, version=ebuild_bin.version, **pkginfo)
	src_version = "6.4.0.3"
	await add_l10n_ebuild(hub, ebuild_bin, version=src_version, **pkginfo)


# vim: ts=4 sw=4 noet
