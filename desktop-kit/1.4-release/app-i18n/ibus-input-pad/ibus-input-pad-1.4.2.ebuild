# Distributed under the terms of the GNU General Public License v2
EAPI="7"

DESCRIPTION="Input Pad for IBus"
HOMEPAGE="https://github.com/fujiwarat/input-pad/wiki"
SRC_URI="https://github.com/fujiwarat/ibus-input-pad/releases/download/1.4.2/ibus-input-pad-1.4.2.tar.gz -> ibus-input-pad-1.4.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-i18n/ibus
	dev-libs/glib:2
	dev-libs/input-pad
	virtual/libintl
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

src_configure() {
	if [ ${PV} == "1.4.2" ]; then
		eapply "${FILESDIR}"/"${P}".patch
	fi

	default
}