# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_VER=$(\
	[[ $(ver_cut 1-2) == $(ver_cut 1-3) ]] \
	&& echo ${PV} \
	|| echo $(ver_cut 1-2)-bugfix$(ver_cut 3)  
)

DESCRIPTION="AJA NTV2 Open Source Static Libs and Headers"
HOMEPAGE="https://github.com/aja-video/ntv2"
SRC_URI="https://github.com/aja-video/ntv2/archive/refs/tags/v${MY_VER}.tar.gz"
S=${WORKDIR}/ntv2-${MY_VER}

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="cuda plugins doc tools"

RESTRICT=( "test" )

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	cuda? ( dev-util/nvidia-cuda-sdk )
	dev-util/cmake
"

src_configure() {
	local mycmakeargs=(
	-DAJA_BUILD_SHARED=ON
	-DAJA_BUILD_LIBS=ON
	-DAJA_BUILD_DRIVER=ON
	-DAJA_BUILD_QT_BASED=OFF
	-DAJA_BUILD_TESTS=OFF
	-DAJA_USE_CLANG=OFF
	-DAJA_BUILD_APPS=$(usex tools ON OFF)
	-DAJA_BUILD_PLUGINS=$(usex plugins ON OFF)
	-DAJA_BUILD_DOCS=$(usex doc ON OFF)
	)

	cmake_src_configure
}

