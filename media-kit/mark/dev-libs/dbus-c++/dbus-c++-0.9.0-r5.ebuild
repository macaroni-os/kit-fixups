# Distributed under the terms of the GNU General Public License v2

EAPI=7

AUTOTOOLS_PRUNE_LIBTOOL_FILES="modules"

inherit autotools virtualx

DESCRIPTION="Provides a C++ API for D-BUS"
HOMEPAGE="https://sourceforge.net/projects/dbus-cplusplus/"
SRC_URI="mirror://sourceforge/dbus-cplusplus/lib${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE="ecore glib test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/expat
	sys-apps/dbus
	ecore? ( dev-libs/efl )
	glib? ( dev-libs/glib:2 )"
DEPEND="${RDEPEND}
	dev-util/cppunit"
BDEPEND="
	virtual/pkgconfig
	test? ( sys-apps/dbus[X] )"

S="${WORKDIR}/lib${P}"

PATCHES=(
	"${FILESDIR}"/${P}-gcc-4.7.patch #424707
	"${FILESDIR}"/${PN}-gcc7.patch #622790
	"${FILESDIR}"/${P}-gcc12.patch
	"${FILESDIR}"/${PN}-0.9.0-enable-tests.patch #873487
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-examples \
		--disable-static \
		--disable-doxygen-docs \
		$(use_enable ecore) \
		$(use_enable glib) \
		$(use_enable test tests) \
		PTHREAD_LIBS=-lpthread
}

src_install() {
	default
	# no static archives
	find "${ED}" -name '*.la' -delete || die
}
