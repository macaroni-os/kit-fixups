# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal

COMMIT="977d8ff093eb0e099fe3b0ef92326d0930a8b873"
DESCRIPTION="Library for parsing, editing, and saving EXIF data"
HOMEPAGE="https://libexif.github.io/"
SRC_URI="https://github.com/libexif/libexif/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
#SRC_URI="https://github.com/${PN}/${PN}/releases/download/${PN}-${PV//./_}-release/${P}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="doc nls static-libs"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.13-pkgconfig.patch
)

src_prepare() {
	default
	sed -i -e '/FLAGS=/s:-g::' configure.ac || die #390249
	# Previously elibtoolize for BSD
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		$(use_enable doc docs) \
		$(use_enable nls) \
		$(use_enable static-libs static) \
		--with-doc-dir="${EPREFIX}"/usr/share/doc/${PF}
}

multilib_src_install() {
	emake DESTDIR="${D}" install
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -delete || die
	rm -f "${ED}"/usr/share/doc/${PF}/{ABOUT-NLS,COPYING} || die
}
