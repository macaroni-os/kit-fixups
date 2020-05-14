# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6,7} )

inherit cmake-multilib cmake-utils python-any-r1

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Tools.git"
	SRC_URI=""
	inherit git-r3
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/KhronosGroup/SPIRV-Tools/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/SPIRV-Tools-${PV}"
fi


DESCRIPTION="Provides an API and commands for processing SPIR-V modules"
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Tools"

LICENSE="Apache-2.0"
SLOT="0"
# Tests fail upon finding symbols that do not match a regular expression
# in the generated library. Easily hit with non-standard compiler flags
RESTRICT="test"

RDEPEND=""
DEPEND="
	${PYTHON_DEPS}
	>=dev-util/spirv-headers-1.4.1
"

multilib_src_configure() {
	local mycmakeargs=(
		"-DSPIRV-Headers_SOURCE_DIR=${EPREFIX}/usr/"
		"-DSPIRV_WERROR=OFF"
	)

	cmake-utils_src_configure
}

multilib_src_install() {
	cmake-utils_src_install

	# create a header file with the commit hash of the current revision
	# vulkan-tools needs this to build
	if [ -n "${EGIT_VERSION}" ] ; then echo "${EGIT_VERSION}" > "${D}/usr/include/${PN}/${PN}-commit.h" || die ; fi
}
