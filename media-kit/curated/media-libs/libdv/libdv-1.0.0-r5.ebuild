# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic multilib-minimal toolchain-funcs

DESCRIPTION="Software codec for dv-format video (camcorders etc)"
HOMEPAGE="http://libdv.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="dev-libs/popt:="
DEPEND="
	${RDEPEND}
	media-libs/libsdl"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-0.99-2.6.patch
	"${FILESDIR}"/${PN}-1.0.0-pic.patch
	"${FILESDIR}"/${PN}-1.0.0-solaris.patch
	"${FILESDIR}"/${PN}-1.0.0-darwin.patch
)

src_prepare() {
	default
	# libdv must be compiled with at most -O1, otherwise we'll
	# get a scary warning about possible undefined behavior.
	filter-flags -O2 -O3
	eautoreconf

	append-cppflags "-I${S}"
}

multilib_src_configure() {
	# bug #622662
	tc-ld-disable-gold

	ECONF_SOURCE="${S}" econf \
		--disable-static \
		--without-debug \
		--disable-gtk \
		$([[ ${CHOST} == *86*-darwin* ]] && echo "--disable-asm")

	if ! multilib_is_native_abi ; then
		sed -i \
			-e 's/ encodedv//' \
			Makefile || die
	fi
}

multilib_src_install_all() {
	einstalldocs

	# no static archives
	find "${D}" -name '*.la' -delete || die
}
