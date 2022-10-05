# Distributed under the terms of the GNU General Public License v2

EAPI=7

SHA='db795a3502e03932081a1aebeeb4cd6147967297'

DESCRIPTION="Support for Rich Text Format files with SDL."
HOMEPAGE="https://libsdl.org/projects/SDL_rtf/"
SRC_URI="https://github.com/libsdl-org/SDL_rtf/archive/${SHA}.tar.gz"
S=$WORKDIR/"SDL_rtf-${SHA}"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="*"
IUSE="+ttf static-libs test"

RDEPEND=">=media-libs/libsdl2-2.0
	ttf? ( media-libs/sdl2-ttf )"
DEPEND="${RDEPEND}"

src_configure() {
	local econfargs=(
		$(use_enable static-libs static)
		$(use_enable test sdltest)
		$(use_enable ttf SDL_ttf)
	)
	econf "${econfargs[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
