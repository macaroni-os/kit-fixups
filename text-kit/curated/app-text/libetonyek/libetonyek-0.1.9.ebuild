# Distributed under the terms of the GNU General Public License v2

EAPI=7

SRC_URI="https://dev-www.libreoffice.org/src/libetonyek/${P}.tar.xz"
KEYWORDS="*"
DESCRIPTION="Library parsing Apple Keynote presentations"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libetonyek"

LICENSE="|| ( GPL-2+ LGPL-2.1 MPL-1.1 )"
SLOT="0"
IUSE="doc static-libs test"
MDDS_VER=1.5
RDEPEND="
	app-text/liblangtag
	dev-libs/librevenge
	dev-libs/libxml2
	dev-util/mdds:$MDDS_VER
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	dev-libs/boost
	media-libs/glm
	sys-devel/libtool
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
	test? ( dev-util/cppunit )
"

src_prepare() {
	default
	[[ -d m4 ]] || mkdir "m4"
	[[ ${PV} == 9999 ]] && eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-werror
		$(use_with doc docs)
		$(use_enable static-libs static)
		$(use_enable test tests)
		--with-mdds=$MDDS_VER
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
