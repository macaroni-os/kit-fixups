# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="Freetype 2 based TrueType font to TeX's PK format converter"
HOMEPAGE="http://tug.org/texlive/"
SRC_URI="mirror://gentoo/texlive-${PV#*_p}-source.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

# Note about blockers: it is a freetype2 based replacement for ttf2pk and
# ttf2tfm from freetype1, so block freetype1.
# It installs some data that collides with
# dev-texlive/texlive-langcjk-2011[source]. Hope it'd be fixed with 2012,
# meanwhile we can start dropping freetype1.
RDEPEND=">=dev-libs/kpathsea-6.2.1
	media-libs/freetype:2
	sys-libs/zlib
	!media-libs/freetype:1"

BDEPEND="virtual/pkgconfig"

S=${WORKDIR}/texlive-${PV#*_p}-source/texk/${PN}

src_prepare() {
	default
	append-cflags -fcommon
}

src_configure() {
	econf --with-system-kpathsea \
		--with-system-freetype2 \
		--with-system-zlib
}
