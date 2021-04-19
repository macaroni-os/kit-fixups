# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

DESCRIPTION="TeX's Computer Modern Fonts for MathML"
HOMEPAGE="http://www.mozilla.org/projects/mathml/fonts/"
SRC_URI="https://dev.gentoo.org/~mgorny/dist/${P}.zip"

LICENSE="bakoma"
SLOT="0"
KEYWORDS="*"

BDEPEND="app-arch/unzip"

S="${WORKDIR}/${PN}"

FONT_S="${S}"
FONT_SUFFIX="ttf"
