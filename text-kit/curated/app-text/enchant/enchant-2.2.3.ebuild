# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="https://abiword.github.io/enchant/"
SRC_URI="https://github.com/AbiWord/enchant/releases/download/v${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2.2"
KEYWORDS="*"

IUSE="aspell +hunspell static-libs test"
REQUIRED_USE="|| ( hunspell aspell )"

# FIXME: depends on unittest++ but through pkgconfig which is a Debian hack, bug #629742
COMMON_DEPENDS="
	>=dev-libs/glib-2.6:2
	aspell? ( app-text/aspell )
	hunspell? ( >=app-text/hunspell-1.2.1:0= )"

RDEPEND="${COMMON_DEPENDS}
	!=app-text/enchant-2.1*:0
	!=app-text/enchant-2.2*:0"

DEPEND="${COMMON_DEPENDS}
	virtual/pkgconfig
"
#	test? ( dev-libs/unittest++ )

RESTRICT="test"

src_configure() {
	econf \
		$(use_with aspell) \
		$(use_with hunspell) \
		$(use_enable static-libs static) \
		--without-hspell \
		--without-voikko \
		--with-hunspell-dir="${EPREFIX}"/usr/share/hunspell/
}

src_compile() {
	emake pkgdatadir=/usr/share/enchant-2 || die
}

src_install() {
	make pkgdatadir=/usr/share/enchant-2 DESTDIR=$D install || die
	find "${D}" -name '*.la' -delete || die
}
