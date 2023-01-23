# Distributed under the terms of the GNU General Public License v2

EAPI=7
XORG_TARBALL_SUFFIX="gz"

inherit xorg-3 meson

DESCRIPTION="X.Org xcvt library and cvt program"
SRC_URI="https://gitlab.freedesktop.org/xorg/lib/libxcvt/-/archive/${P}/${PN}-${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}/${PN}-${PN}-${PV}"

# Override xorg-3's src_prepare
src_prepare() {
	default
}

src_install() {
	meson_src_install

	rm \
			"${ED}"/usr/bin/cvt \
			"${ED}"/usr/share/man/man1/cvt.1 || die
}
