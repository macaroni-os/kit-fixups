# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Minimal mDNS resolver (and announcer) library"
HOMEPAGE="https://videolabs.io"
SRC_URI="https://github.com/videolabs/${PN}/releases/download/${PV}/${P/lib/}.tar.xz"

KEYWORDS="*"
LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="examples test"
RESTRICT="!test? ( test )"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${P/lib/}"

src_configure() {
	local emesonargs=(
		$(meson_feature examples)
		$(meson_feature test tests)
	)
	meson_src_configure
}
