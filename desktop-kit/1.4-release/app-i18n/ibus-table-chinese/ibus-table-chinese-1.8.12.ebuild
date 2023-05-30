# Distributed under the terms of the GNU General Public License v2
EAPI="7"
CMAKE_IN_SOURCE_BUILD="1"
CMAKE_MAKEFILE_GENERATOR="emake"

inherit cmake-utils

DESCRIPTION="Chinese tables for IBus-Table"
HOMEPAGE="https://github.com/definite/ibus-table-chinese"
SRC_URI="https://github.com/mike-fabian/ibus-table-chinese/releases/download/1.8.12/ibus-table-chinese-1.8.12.tar.gz -> ibus-table-chinese-1.8.12.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-i18n/ibus-table"
DEPEND="${RDEPEND}
	dev-util/cmake-fedora"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_FEDORA_TMP_DIR="${T}"
		-DDATA_DIR="${EPREFIX}"/usr/share
		-DMANAGE_DEPENDENCY_PACKAGE_EXISTS_CMD=false
		-DPRJ_DOC_DIR="${EPREFIX}"/usr/share/doc/${PF}
	)
	cmake-utils_src_configure
}
