# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Headers.git"
	SRC_URI=""
	inherit git-r3
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/KhronosGroup/SPIRV-Headers/archive/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/SPIRV-Headers-${PV}"
fi


DESCRIPTION="Machine-readable files for the SPIR-V Registry"
HOMEPAGE="https://www.khronos.org/registry/spir-v/"

LICENSE="MIT"
SLOT="0"
