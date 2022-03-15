# Distributed under the terms of the GNU General Public License v2

EAPI=7

MDDS_VER="2.0"

DESCRIPTION="Library parsing Apple Keynote presentations"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libetonyek"
SRC_URI="https://dev-www.libreoffice.org/src/libetonyek/${P}.tar.xz"

LICENSE="|| ( GPL-2+ LGPL-2.1 MPL-1.1 )"
SLOT="0"
IUSE="doc static-libs test"
KEYWORDS="*"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"
RDEPEND="
	app-text/liblangtag
	dev-libs/librevenge
	dev-libs/libxml2
	dev-util/mdds:${MDDS_VER}
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	dev-libs/boost
	media-libs/glm
	sys-devel/libtool
	test? ( dev-util/cppunit )
"

src_prepare() {
	default
	[[ -d m4 ]] || mkdir "m4"
}

src_configure() {
	local myeconfargs=(
		--disable-werror
		--with-mdds="${MDDS_VER}"
		$(use_with doc docs)
		$(use_enable static-libs static)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -type f -delete || die
}
