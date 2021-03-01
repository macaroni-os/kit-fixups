# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit toolchain-funcs

DESCRIPTION="An implementation of the IDNA2008 specifications (RFCs 5890, 5891, 5892, 5893)"
HOMEPAGE="https://www.gnu.org/software/libidn/#libidn2 https://gitlab.com/libidn/libidn2"
SRC_URI="mirror://gnu/libidn/${P}.tar.gz"

LICENSE="GPL-2+ LGPL-3+"
SLOT="0/2"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND="
	dev-libs/libunistring
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-lang/perl
	sys-apps/help2man
"
S=${WORKDIR}/${P/a/}

src_configure() {
	econf \
		CC_FOR_BUILD="$(tc-getBUILD_CC)" \
		$(use_enable static-libs static) \
		--disable-doc \
		--disable-gcc-warnings \
		--disable-gtk-doc
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
