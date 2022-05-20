# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="User Tools from libqtxdg"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-0.11.0"
RDEPEND="
	>=dev-libs/libqtxdg-3.9.1
	>=dev-qt/qtcore-5.15:5
"
DEPEND="${RDEPEND}"
