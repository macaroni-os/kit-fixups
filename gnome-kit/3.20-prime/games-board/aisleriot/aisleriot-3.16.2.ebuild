# Distributed under the terms of the GNU General Public License v2

EAPI="5"

GCONF_DEBUG="yes"

inherit eutils gnome-games

DESCRIPTION="A collection of solitaire card games for GNOME"
HOMEPAGE="http://live.gnome.org/Aisleriot"

LICENSE="GPL-3 LGPL-3 FDL-1.1"
SLOT="0"
KEYWORDS="*"
IUSE="gnome kde pysolfc sound valgrind"

RDEPEND="
	!gnome-extra/gnome-games

	>=app-arch/gzip-1.6
	>=dev-scheme/guile-2.0.11[deprecated,regex]
	>=gnome-base/gconf-3.2.6
	>=gnome-base/librsvg-2.40.2
	>=x11-libs/libSM-1.2.2

	kde? ( dev-qt/qtsvg:4 )
	pysolfc? (  games-board/pysolfc )
	sound? ( >=media-libs/libcanberra-0.30[gtk3] )
	valgrind? (  dev-util/valgrind )
"
DEPEND="
	dev-util/appdata-tools
	>=app-text/yelp-tools-3.12.1
"

DOCS="AUTHORS ChangeLog NEWS TODO"

src_configure() {
	local myconf=()
	local card_theme_formats="svg,fixed"

	if ! use gnome; then
		myconf+=(--with-platform=gtk-only --with-help-method=library)
	fi

	if use kde; then
		card_theme_formats+=",kde,native"
		myconf+=(--with-kde-card-theme-path="${EPREFIX}"/usr/share/apps/carddecks)
	fi

	if use pysolfc; then
		card_theme_formats+=",pysol"
		myconf+=(--with-pysol-card-theme-path="${GAMES_DATADIR}"/pysolfc)
	fi

	gnome-games_src_configure \
		--disable-schemas-compile \
		--with-card-theme-formats="${card_theme_formats}" \
		--with-valgrind-dir="${EPREFIX}"/usr/$(get_libdir)/valgrind \
		"${myconf[@]}" \
		$(use_enable sound)
}
