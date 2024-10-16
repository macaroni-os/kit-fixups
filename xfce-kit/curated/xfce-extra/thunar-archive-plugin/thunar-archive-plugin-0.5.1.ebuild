# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils

DESCRIPTION="Archive plug-in for the Thunar filemanager"
HOMEPAGE="https://goodies.xfce.org/projects/thunar-plugins/thunar-archive-plugin"
SRC_URI="https://archive.xfce.org/src/thunar-plugins/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=xfce-base/libxfce4util-4.12:=
	>=xfce-base/exo-0.10:=
	>=xfce-base/thunar-1.7:="
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	gnome2_icon_cache_update
	
	ewarn "The Thunar Archive Plugin currently includes support for Xarchiver, File Roller (GNOME archive manager), Ark (KDE archive manager) and Engrampa (MATE archive manager)."
	einfo "Thunar archive plugin requires an archive manager to function.  Officially supported Archive Managers are in meta-repo: Xarchiver, File Roller (GNOME archive manager), Ark (KDE arvhive manager) and Engrampa (Mate archive manager)."
}

pkg_postrm() {
	gnome2_icon_cache_update
}
