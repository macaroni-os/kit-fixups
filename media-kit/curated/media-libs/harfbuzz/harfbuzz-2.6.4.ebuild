# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )

inherit flag-o-matic libtool python-any-r1 xdg-utils

DESCRIPTION="An OpenType text shaping engine"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/HarfBuzz"

SRC_URI="https://www.freedesktop.org/software/${PN}/release/${P}.tar.xz"
KEYWORDS="*"

LICENSE="Old-MIT ISC icu"
SLOT="0/0.9.18" # 0.9.18 introduced the harfbuzz-icu split; bug #472416

IUSE="+cairo debug +glib +graphite icu +introspection static-libs test +truetype"
REQUIRED_USE="introspection? ( glib )"

RDEPEND="
	cairo? ( >=x11-libs/cairo-1.8.0:= )
	glib? ( >=dev-libs/glib-2.38:2 )
	graphite? ( >=media-gfx/graphite2-1.2.0:= )
	icu? ( >=dev-libs/icu-51.2-r1:= )
	introspection? ( >=dev-libs/gobject-introspection-1.34:= )
	truetype? ( >=media-libs/freetype-2.4.2:2= )
"
DEPEND="${RDEPEND}
	test? ( ${PYTHON_DEPS} )
"
BDEPEND="
	dev-util/gtk-doc-am
	virtual/pkgconfig
"

pkg_setup() {
	use test && python-any-r1_pkg_setup
	if ! use debug ; then
		append-cppflags -DHB_NDEBUG
	fi
}

src_prepare() {
	default

	xdg_environment_reset

	if [[ ${CHOST} == *-darwin* || ${CHOST} == *-solaris* ]] ; then
		# on Darwin/Solaris we need to link with g++, like automake defaults
		# to, but overridden by upstream because on Linux this is not
		# necessary, bug #449126
		sed -i \
			-e 's/\<LINK\>/CXXLINK/' \
			src/Makefile.am || die
		sed -i \
			-e '/libharfbuzz_la_LINK = /s/\<LINK\>/CXXLINK/' \
			src/Makefile.in || die
		sed -i \
			-e '/AM_V_CCLD/s/\<LINK\>/CXXLINK/' \
			test/api/Makefile.in || die
	fi

	[[ ${PV} == 9999 ]] && eautoreconf
	elibtoolize # for Solaris

	# bug 618772
	append-cxxflags -std=c++14
}

src_configure() {
	# harfbuzz-gobject only used for instrospection, bug #535852
	local myeconfargs=(
		--without-coretext
		--without-fontconfig #609300
		--without-uniscribe
		$(use_enable static-libs static)
		$(use_with cairo)
		$(use_with glib)
		$(use_with introspection gobject)
		$(use_with graphite graphite2)
		$(use_with icu)
		$(use_enable introspection)
		$(use_with truetype freetype)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"

	ln -s "${S}"/docs/html docs/html
}

src_install() {
	default
	einstalldocs
	find "${ED}" -name "*.la" -delete || die
}
