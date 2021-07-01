# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit autotools python-single-r1

DESCRIPTION="Codec for karaoke and text encapsulation for Ogg"
HOMEPAGE="https://code.google.com/p/libkate/"
SRC_URI="https://libkate.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

IUSE="debug doc wxwidgets"
REQUIRED_USE="wxwidgets? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	media-libs/libogg:=
	media-libs/libpng:0=
"
BDEPEND="${DEPEND}
	virtual/pkgconfig
	sys-devel/flex
	sys-devel/bison
	doc? ( app-doc/doxygen )
"
RDEPEND="${DEPEND}
	wxwidgets? (
		${PYTHON_DEPS}
		dev-python/wxpython:4.0[${PYTHON_USEDEP}]
		media-libs/liboggz )
"

PATCHES=( ${FILESDIR}/${P}-python3.patch )

pkg_setup() {
	use wxwidgets && python-single-r1_pkg_setup
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local ECONF_SOURCE=${S}
	econf \
		--disable-static \
		$(use_enable debug) \
		$(use_enable doc) \
		$(usex wxwidgets '' 'PYTHON=:')
}

src_install() {
	default
	einstalldocs
	find "${D}" -name '*.la' -delete || die
	use wxwidgets && python_fix_shebang "${D}"
}
