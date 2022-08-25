# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools eutils

DESCRIPTION="Open source Text Summarizer, as used in newer releases of abiword and kword"
HOMEPAGE="https://github.com/neopunisher/Open-Text-Summarizer"
SRC_URI="https://github.com/neopunisher/Open-Text-Summarizer/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-libs/glib:2
	>=dev-libs/libxml2-2.4.23
	>=dev-libs/popt-1.5
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

PATCHES=(
	"${FILESDIR}"/${PN}-0.5.0-math.patch
	"${FILESDIR}"/${PN}-0.5.0-automake-1.13.patch
	"${FILESDIR}"/${PN}-0.5.0-fix-no-rule-to-make-libots.patch
	"${FILESDIR}"/${PN}-0.5.0-fix-underlinking.patch
)

src_prepare() {
	default
	touch "${S}"/gtk-doc.make
	mv configure.in configure.ac || die
	sed -i -e 's/en.xml$//' dic/Makefile.am || die
	eautoreconf
}

src_configure() {
	# bug 97448
	econf \
		--disable-gtk-doc \
		--disable-static
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}
