# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xorg-3

DESCRIPTION="create an index of scalable font files for X"

KEYWORDS="*"
IUSE=""

COMMON_DEPEND="
	x11-libs/libfontenc
	media-libs/freetype:2
	sys-libs/zlib
	app-arch/bzip2"
DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto"
RDEPEND="${COMMON_DEPEND}
	!<x11-apps/mkfontdir-1.2.0"

XORG_CONFIGURE_OPTIONS=(
	--with-bzip2
)
