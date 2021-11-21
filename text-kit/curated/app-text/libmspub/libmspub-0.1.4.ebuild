# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

SRC_URI="https://dev-www.libreoffice.org/src/libmspub/${P}.tar.xz"
KEYWORDS="*"
DESCRIPTION="Library parsing Microsoft Publisher documents"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libmspub"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="doc static-libs"

BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"
RDEPEND="
	dev-libs/icu:=
	dev-libs/librevenge
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	dev-libs/boost
	sys-devel/libtool
"

PATCHES=( "${FILESDIR}/${P}-gcc10.patch" )

src_prepare() {
	default
	[[ -d m4 ]] || mkdir "m4"
}

src_configure() {
	append-cxxflags -std=c++14

	local myeconfargs=(
		--disable-werror
		$(use_with doc docs)
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -type f -delete || die
}
