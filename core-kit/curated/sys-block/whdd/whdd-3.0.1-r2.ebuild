# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Diagnostic and recovery tool for block devices"
HOMEPAGE="https://whdd.github.io"

inherit toolchain-funcs

SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}-rel.tar.gz"
KEYWORDS="*"

LICENSE="GPL-3"
SLOT="0"

DEPEND="dev-util/dialog:=
	sys-libs/ncurses:="
RDEPEND="${DEPEND}
	sys-apps/smartmontools"

src_compile() {
	tc-export CC
	default
}
