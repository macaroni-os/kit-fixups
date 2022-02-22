# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="An assembler for x86 and x86_64 instruction sets"
HOMEPAGE="https://yasm.tortall.net/"
SRC_URI="https://www.tortall.net/projects/yasm/releases/${P}.tar.gz"

LICENSE="BSD-2 BSD || ( Artistic GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="*"
IUSE="nls"

BDEPEND="
	nls? ( sys-devel/gettext )
"
DEPEND="
	nls? ( virtual/libintl )
"
RDEPEND="${DEPEND}
"

src_configure() {
	local myconf=(
		CC_FOR_BUILD="$(tc-getBUILD_CC)"
		CCLD_FOR_BUILD="$(tc-getBUILD_CC)"
		--disable-warnerror
		--disable-python
		--disable-python-bindings
		$(use_enable nls)
	)

	econf "${myconf[@]}"
}

src_test() {
	# https://bugs.gentoo.org/718870
	emake -j1 check
}
