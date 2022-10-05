# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic multiprocessing qmake-utils xdg

SRC_URI="https://mkvtoolnix.download/sources/${P}.tar.xz"
KEYWORDS="*"

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="https://mkvtoolnix.download/ https://gitlab.com/mbunkus/mkvtoolnix"

LICENSE="GPL-2"
SLOT="0"
IUSE="dbus debug dvd gui nls pch test"
RESTRICT="!test? ( test )"

# check NEWS.md for build system changes entries for boost/libebml/libmatroska
# version requirement updates and other packaging info
RDEPEND="
	dev-libs/boost:=
	dev-libs/gmp:=
	>=dev-libs/pugixml-1.11:=
	media-libs/flac:=
	media-libs/libogg:=
	media-libs/libvorbis:=
	sys-libs/zlib
	dvd? ( media-libs/libdvdread:= )
	dev-qt/qtcore:5
	gui? (
		dev-qt/qtsvg:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
		dev-qt/qtconcurrent:5
		dev-qt/qtmultimedia:5
	)
	app-text/cmark:0=
	dbus? ( dev-qt/qtdbus:5 )
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
"
BDEPEND="
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-ruby/rake
	virtual/pkgconfig
	nls? (
		sys-devel/gettext
		app-text/po4a
	)
"

PATCHES=(
	"${FILESDIR}"/mkvtoolnix-58.0.0-qt5dbus.patch
	"${FILESDIR}"/mkvtoolnix-67.0.0-no-uic-qtwidgets.patch
	"${FILESDIR}"/${P}-used_bundled_libs.patch
)

src_prepare() {
	default

	# bug #692018
	sed -i -e 's/pandoc/diSaBlEd/' ac/pandoc.m4 || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable debug)
		$(usex pch "" --disable-precompiled-headers)
		$(use_enable dbus)

		# Qt (of some version) is always needed, even for non-GUI builds,
		# to do e.g. MIME detection. See e.g. bug #844097.
		# But most of the Qt deps are conditional on a GUI build.
		--disable-qt6
		--enable-qt5
		$(use_enable gui)
		--with-qmake="$(qt5_get_bindir)"/qmake

		$(use_with dvd dvdread)
		$(use_with nls gettext)
		$(usex nls "" --with-po4a-translate=false)
		--disable-update-check
		--disable-optimization
		--with-boost="${ESYSROOT}"/usr
		--with-boost-libdir="${ESYSROOT}"/usr/$(get_libdir)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	rake V=1 -j$(makeopts_jobs) || die
}

src_test() {
	rake V=1 -j$(makeopts_jobs) tests:unit || die
	rake V=1 -j$(makeopts_jobs) tests:run_unit || die
}

src_install() {
	DESTDIR="${D}" rake -j$(makeopts_jobs) install || die

	einstalldocs
	dodoc NEWS.md
	doman doc/man/*.1
}
