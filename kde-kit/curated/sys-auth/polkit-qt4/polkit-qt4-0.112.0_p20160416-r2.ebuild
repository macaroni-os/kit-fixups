# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P="${P/qt4/qt-1}"
inherit cmake-utils

DESCRIPTION="PolicyKit Qt API wrapper library"
HOMEPAGE="https://api.kde.org/kdesupport-api/polkit-qt-1-apidocs/"
SRC_URI="https://dev.gentoo.org/~kensington/distfiles/${MY_P}.tar.xz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 x86 ~x86-fbsd"
IUSE="debug"

RDEPEND="
	dev-libs/glib:2
	dev-qt/qtcore:4[glib]
	dev-qt/qtdbus:4
	dev-qt/qtgui:4[glib]
	>=sys-auth/polkit-0.103
"
DEPEND="${RDEPEND}"

DOCS=( AUTHORS README README.porting TODO )

S=${WORKDIR}/${MY_P}

src_configure() {
	local mycmakeargs=(
		-DBUILD_EXAMPLES=OFF
		-DUSE_QT4=ON
		-DUSE_QT5=OFF
	)

	cmake-utils_src_configure
}
