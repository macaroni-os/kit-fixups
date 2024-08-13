# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="C preprocessor interface to the make utility"
HOMEPAGE="https://www.x.org/wiki/ https://cgit.freedesktop.org/"
SRC_URI="mirror://xorg/util/${P}.tar.xz"
KEYWORDS="*"

LICENSE="MIT"
SLOT="0"
IUSE=""

BDEPEND="
	virtual/pkgconfig
"
RDEPEND="
	x11-misc/xorg-cf-files
"
DEPEND="
	${LIVE_DEPEND}
	${RDEPEND}
	x11-base/xorg-proto
"

PATCHES=(
	# don't use Sun compilers on Solaris, we want GCC from prefix
#	"${FILESDIR}"/${PN}-1.0.7-sun-compiler.patch
	"${FILESDIR}"/${PN}-1.0.8-cpp-args.patch
	"${FILESDIR}"/${PN}-1.0.9-no-get-gcc.patch
	"${FILESDIR}"/${PN}-1.0.8-respect-LD.patch
	"${FILESDIR}"/${PN}-1.0.8-xmkmf-pass-cc-ld.patch
)

src_prepare() {
	default
}

src_configure() {
	local econfargs=(
		--disable-selective-werror
	)

	econf "${econfargs[@]}"
}
