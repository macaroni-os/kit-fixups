# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Command line interface (CLI) for Joomla"
HOMEPAGE="https://www.joomlatools.com/developer/tools/console/"
SRC_URI=""

GITHUB_REPO="${PN}"
GITHUB_USER="joomlatools"
GITHUB_TAG="${PV}"

if [ ${PV} == "9999" ] ; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/${GITHUB_USER}/${PN}.git"
else
	SRC_URI="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/v${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"
	KEYWORDS="*"
fi

LICENSE="MPL-2.0"
SLOT="0"
IUSE=""
DEPEND=">=dev-php/symfony-console-2.7"
RDEPEND="${DEPEND}"

PATCHES=("${FILESDIR}/joomlatools-update-paths.patch")

src_install() {
	insinto "/usr/share/php/"
	doins -r src/Joomlatools
	insinto "/usr/share/php/Joomlatools/Console"
	doins ${FILESDIR}/autoload.php 
	dobin bin/joomla
}
