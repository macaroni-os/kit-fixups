# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
CMAKE_BUILD_TYPE=Release

inherit cmake-utils python-any-r1

DESCRIPTION="A Multilevel Parallel Object-Oriented Framework for Design Optimization,
			Parameter Estimation, Uncertainty Quantification, and Sensitivity Analysis"
HOMEPAGE="https://dakota.sandia.gov/"
SRC_URI="https://dakota.sandia.gov/sites/default/files/distributions/public/${P}-release-public.src-UI.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	virtual/blas
	virtual/lapack
	dev-libs/boost
	>=dev-cpp/eigen-3
	dev-libs/tinyxml
	x11-libs/motif
	x11-libs/libXpm
"
DEPEND="${DEPEND}"
BDEPEND="
	>=dev-lang/perl-5
	${PYTHON_DEPS}
"

S="${WORKDIR}/${P}-release-public.src-UI"

src_prepare() {
	rm -r packages/external/{eigen3,acro/tpl/tinyxml} || die

	for source_file in $(grep -rl "<tinyxml/" packages/external/acro/packages); do
		sed -i -e "s#<tinyxml/#<#" ${source_file}
	done

	cmake-utils_src_prepare
}

src_configure() {
	for CMakeList in $(find ${S} -name CMakeLists.txt); do
		sed -i -e "s#DESTINATION lib#DESTINATION $(get_libdir)#" ${CMakeList}
	done

	sed -i -e "/tpl.tinyxml/d" -e "s# tinyxml)#)#" src/CMakeLists.txt
	sed -i -e "/TINYXML_DIR/d" packages/external/acro/CMakeLists.txt
	sed -i -e "/add_subdirectory(tinyxml)/d" packages/external/acro/tpl/CMakeLists.txt
	sed -i -e "s#ACX_TINYXML.*#ACX_TINYXML#" packages/external/acro/configure.ac
	sed -i -e "s#ACX_TINYXML.*#ACX_TINYXML#" packages/external/acro/bootstrap/root/configure.ac

	sed -i -e "/install.*eigen/d" packages/CMakeLists.txt

	sed -i -e "s#INSTALL_LIB_DIR_DEFAULT \"lib#INSTALL_LIB_DIR_DEFAULT \"$(get_libdir)#" \
		packages/external/trilinos/cmake/tribits/core/package_arch/TribitsGlobalMacros.cmake

	use test && DAKOTA_ENABLE_TESTS='True'
	local mycmakeargs=(
		-DDAKOTA_ENABLE_TESTS=$(usex test 'ON' 'OFF')
		-DHAVE_TINYXML='ON'
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	rm ${D}/usr/include/cblas.h
}
