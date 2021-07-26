# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xorg-3

DESCRIPTION="Locale and ISO 2022 support for Unicode terminals"

KEYWORDS="*"
IUSE=""
RDEPEND="sys-libs/zlib
	x11-libs/libX11
	x11-libs/libfontenc"
DEPEND="${RDEPEND}"

src_prepare() {
	# posix_openpt() call needs POSIX 2004, bug #415949
	sed -i 's/-D_XOPEN_SOURCE=500/-D_XOPEN_SOURCE=600/' configure.ac || die
	xorg-3_src_prepare
}