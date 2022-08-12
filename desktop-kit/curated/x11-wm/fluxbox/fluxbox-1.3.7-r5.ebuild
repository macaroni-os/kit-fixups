# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools flag-o-matic toolchain-funcs prefix xdg xdg-utils

IUSE="nls xinerama bidi +truetype +imlib +slit +systray +toolbar vim-syntax"

REQUIRED_USE="systray? ( toolbar )"

DESCRIPTION="X11 window manager featuring tabs and an iconbar"

SRC_URI="https://github.com/fluxbox/fluxbox/archive/refs/tags/Release-${PV//./_}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="http://www.fluxbox.org"
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"

BDEPEND="media-gfx/imagemagick"

RDEPEND="
	!!<=x11-misc/fbdesk-1.2.1
	!!<x11-themes/fluxbox-styles-fluxmod-20040809-r1
	bidi? ( >=dev-libs/fribidi-0.19.2 )
	imlib? ( >=media-libs/imlib2-1.2.0[X] )
	truetype? ( media-libs/freetype )
	vim-syntax? ( app-vim/fluxbox-syntax )
	x11-libs/libXext
	x11-libs/libXft
	x11-libs/libXpm
	x11-libs/libXrandr
	x11-libs/libXrender
	xinerama? ( x11-libs/libXinerama )
	|| ( x11-misc/gxmessage x11-apps/xmessage )
"
DEPEND="
	${RDEPEND}
	bidi? ( virtual/pkgconfig )
	nls? ( sys-devel/gettext )
	x11-base/xorg-proto
"

PATCHES=(
	# We need to be able to include directories rather than just plain
	# files in menu [include] items. This patch will allow us to do clever
	# things with style ebuilds.
	"${FILESDIR}"/${P}-gentoo_style_location.patch
	"${FILESDIR}"/${P}-osx-has-otool.patch
	# Fix bug #551522; 1.3.8 will render this obsolete
	"${FILESDIR}"/${P}-fix-hidden-toolbar.patch
	# Fix bug #1138; 1.3.8 will render this obsolete
	"${FILESDIR}"/${P}-fix-compare-pointer-with-int.patch
	# Fix bug #1103; 1.3.8 will render this obsolete
	"${FILESDIR}"/${P}-fix-tab-selection.patch
	# Fix bug #1055; 1.3.8 will render this obsolete
	"${FILESDIR}"/${P}-fix-tabbing-unfocusable-clients.patch
	"${FILESDIR}"/${P}-fix-infinite-loop-menu.patch
	"${FILESDIR}"/${P}-fix-segfault-on-no-fonts.patch
	"${FILESDIR}"/${P}-fix-stdmax-compilation-error.patch
	"${FILESDIR}"/${P}-fix-transient-dialog-placement.patch
)

post_src_unpack() {
	mv "${WORKDIR}"/fluxbox-Release-${PV//./_} "${S}" || die
}
src_prepare() {
	default

	eprefixify util/fluxbox-generate_menu.in

	# Add in the Funtoo -r number to fluxbox -version output.
	if [[ "${PR}" == "r0" ]] ; then
		suffix="funtoo"
	else
		suffix="funtoo-${PR}"
	fi
	sed -i \
		-e "s~\(__fluxbox_version .@VERSION@\)~\1-${suffix}~" \
		version.h.in || die "version sed failed"

	eautoreconf
}

src_configure() {
	xdg_environment_reset
	# 1.3.8 Will default to C++11 and fix the code to compile properly.
	append-cppflags -std=c++98
	use bidi && append-cppflags "$($(tc-getPKG_CONFIG) --cflags fribidi)"

	econf $(use_enable bidi fribidi ) \
		$(use_enable imlib imlib2) \
		$(use_enable nls) \
		$(use_enable slit ) \
		$(use_enable systray ) \
		$(use_enable toolbar ) \
		$(use_enable truetype xft) \
		$(use_enable xinerama) \
		--sysconfdir="${EPREFIX}"/etc/X11/${PN}
}

src_compile() {
	default

	ebegin "Creating a menu file (may take a while)"
	mkdir -p "${T}/home/.fluxbox" || die "mkdir home failed"
	# Call fluxbox-generate_menu through bash since it lacks +x
	# chmod 744 may be an equal fix
	MENUFILENAME="${S}/data/menu" MENUTITLE="Fluxbox ${PV}" \
		CHECKINIT="no. go away." HOME="${T}/home" \
		bash "${S}/util/fluxbox-generate_menu" -is -ds \
		|| die "menu generation failed"
	eend $?
}

src_install() {
	emake DESTDIR="${D}" STRIP="" install
	dodoc README* AUTHORS TODO* ChangeLog NEWS

	# Install the generated menu
	insinto /usr/share/fluxbox
	doins data/menu

	insinto /usr/share/xsessions
	doins "${FILESDIR}"/${PN}.desktop

	exeinto /etc/X11/Sessions
	newexe "${FILESDIR}"/${PN}.xsession fluxbox

	# Styles menu framework
	insinto /usr/share/fluxbox/menu.d/styles
	doins "${FILESDIR}"/styles-menu-fluxbox
	doins "${FILESDIR}"/styles-menu-commonbox
	doins "${FILESDIR}"/styles-menu-user
}

