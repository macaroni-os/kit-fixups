# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-multilib

DESCRIPTION="Implementation of the codec specified in the JPEG-2000 Part-1 standard"
HOMEPAGE="https://www.ece.uvic.ca/~mdadams/jasper/"

SRC_URI="https://github.com/mdadams/${PN}/archive/version-${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="*"
S="${WORKDIR}/${PN}-version-${PV}"

# We limit memory usage to 128 MiB by default, specified in bytes
: ${JASPER_MEM_LIMIT:=134217728}

LICENSE="JasPer2.0"
SLOT="0/4"
IUSE="doc jpeg opengl"

RDEPEND="
	jpeg? ( >=virtual/jpeg-0-r2:0[${MULTILIB_USEDEP}] )
	opengl? (
		>=virtual/opengl-7.0-r1:0[${MULTILIB_USEDEP}]
		>=media-libs/freeglut-2.8.1:0[${MULTILIB_USEDEP}]
		virtual/glu[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
		x11-libs/libXmu[${MULTILIB_USEDEP}]
	)"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? ( app-doc/doxygen )
"

multilib_src_configure() {
	local mycmakeargs=(
		-DALLOW_IN_SOURCE_BUILD=OFF
		-DBASH_PROGRAM="${EPREFIX}"/bin/bash
		-DJAS_ENABLE_ASAN=OFF
		-DJAS_ENABLE_LSAN=OFF
		-DJAS_ENABLE_MSAN=OFF
		-DJAS_ENABLE_SHARED=ON
#		-DJAS_ENABLE_STRICT=ON
		-DJAS_ENABLE_USAN=OFF
		-DCMAKE_INSTALL_DOCDIR=share/doc/${PF}

		# JPEG
		-DJAS_ENABLE_LIBJPEG=$(usex jpeg)

		# OpenGL
		-DJAS_ENABLE_OPENGL=$(usex opengl)

		# Doxygen
		-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=$(multilib_native_usex doc OFF ON)
	)
	cmake-utils_src_configure
}
