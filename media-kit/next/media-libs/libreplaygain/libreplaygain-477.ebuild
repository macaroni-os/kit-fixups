# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

# svn export http://svn.musepack.net/libreplaygain libreplaygain-${PV}
# tar -cJf libreplaygain-${PV}.tar.xz libreplaygain-${PV}

DESCRIPTION="Replay Gain library from Musepack"
HOMEPAGE="https://www.musepack.net/"
SRC_URI="https://dev.gentoo.org/~ssuominen/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

PATCHES=( "${FILESDIR}"/${PN}-static-libs.patch )

src_prepare() {
	cmake_src_prepare

	sed -i -e '/CMAKE_C_FLAGS/d' CMakeLists.txt || die
}

src_install() {
	cmake_src_install
	insinto /usr/include
	doins -r include/replaygain
}
