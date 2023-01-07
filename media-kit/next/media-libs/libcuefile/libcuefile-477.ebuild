# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

# svn export http://svn.musepack.net/libcuefile/trunk libcuefile-${PV}
# tar -cJf libcuefile-${PV}.tar.xz libcuefile-${PV}

DESCRIPTION="Cue File library from Musepack"
HOMEPAGE="https://www.musepack.net/"
SRC_URI="https://dev.gentoo.org/~ssuominen/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

PATCHES=( "${FILESDIR}"/${PN}-static-libs.patch )

pkg_pretend() {
	echo $SRC_URI
}

src_install() {
	cmake_src_install

	insinto /usr/include
	doins -r include/cuetools
}
