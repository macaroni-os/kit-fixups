# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Tools for using the Ogg Vorbis sound file format"
HOMEPAGE="https://xiph.org/vorbis/"
SRC_URI="https://ftp.osuosl.org/pub/xiph/releases/vorbis/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="flac kate nls +ogg123 speex"

RDEPEND="
	media-libs/libvorbis
	media-libs/opusfile

	flac? ( media-libs/flac:= )
	kate? ( media-libs/libkate )
	ogg123? (
		media-libs/libao
		net-misc/curl
	)
	speex? ( media-libs/speex )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

src_configure() {
	local myeconfargs=(
		$(use_with flac)
		$(use_with kate)
		$(use_enable nls)
		$(use_enable ogg123)
		$(use_with speex)
	)
	econf "${myeconfargs[@]}"
}
