# Distributed under the terms of the GNU General Public License v2

EAPI=7

GTEST_VERSION="1.7.0"

inherit eutils

DESCRIPTION="Modern Video Toolkit"
HOMEPAGE="https://movit.sesse.net/"
# Tests need gtest, makefile unconditionally builds tests, so ... yey!
SRC_URI="
	https://movit.sesse.net/${P}.tar.gz
	https://github.com/google/googletest/archive/refs/tags/release-${GTEST_VERSION}.tar.gz -> googletest-${GTEST_VERSION}.tar.gz
"
LICENSE="GPL-2+"
SLOT="0"

KEYWORDS="*"
IUSE=""

RDEPEND="media-libs/mesa[X(+)]
	dev-cpp/eigen
	media-libs/libepoxy
	sci-libs/fftw
	media-libs/libsdl2
"
DEPEND="${RDEPEND}"

src_prepare() {
	# GCC 12 fix
	sed -i "1i #include <memory>" test_util.cpp

	default
}

src_configure() {
	econf --disable-static
}

src_compile() {
	GTEST_DIR="${WORKDIR}/googletest-release-${GTEST_VERSION}" emake
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
