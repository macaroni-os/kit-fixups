# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

SRC_URI="https://dev-www.libreoffice.org/src/libcdr/${P}.tar.xz"
KEYWORDS="amd64 ~arm ~arm64 ~hppa ppc ppc64 ~sparc x86"

DESCRIPTION="Library parsing the Corel cdr documents"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libcdr"

LICENSE="MPL-2.0"
SLOT="0"
IUSE="doc static-libs test"

RDEPEND="
	dev-libs/icu:=
	dev-libs/librevenge
	media-libs/lcms:2
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	dev-libs/boost
"
BDEPEND="
	sys-devel/libtool
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
	test? ( dev-util/cppunit )
"

src_prepare() {
	default
	[[ -d m4 ]] || mkdir "m4"
}

src_configure() {
	# bug 619448
	append-cxxflags -std=c++14

	local myeconfargs=(
		$(use_with doc docs)
		$(use_enable static-libs static)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
