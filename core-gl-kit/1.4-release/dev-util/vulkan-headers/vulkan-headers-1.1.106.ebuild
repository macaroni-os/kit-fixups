# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/Vulkan-Headers.git"
	inherit git-r3
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/KhronosGroup/Vulkan-Headers/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/Vulkan-Headers-${PV}"
fi

DESCRIPTION="Vulkan Header files and API registry"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Headers"

LICENSE="Apache-2.0"
SLOT="0"

# Old packaging will cause file collisions
RDEPEND="!<=media-libs/vulkan-loader-1.1.70.0-r999"
