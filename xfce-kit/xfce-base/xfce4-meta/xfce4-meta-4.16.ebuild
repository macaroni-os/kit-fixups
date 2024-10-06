# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The Xfce Desktop Environment (meta package)"
HOMEPAGE="https://www.xfce.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE="minimal +svg upower"

RDEPEND="x11-themes/hicolor-icon-theme
	>=xfce-base/exo-4.16.0
	>=xfce-base/garcon-4.16.0
	>=xfce-base/libxfce4ui-4.16.0
	>=xfce-base/libxfce4util-4.16.0
	>=xfce-base/thunar-4.16.0
	>=xfce-base/xfce4-appfinder-4.16.0
	>=xfce-base/xfce4-panel-4.16.0
	>=xfce-base/xfce4-session-4.16.0
	>=xfce-base/xfce4-settings-4.16.0
	x11-terms/xfce4-terminal
	>=xfce-base/xfconf-4.16.0
	>=xfce-base/xfdesktop-4.16.0
	>=xfce-base/xfwm4-4.16.0
	>=xfce-extra/thunar-volman-4.16.0
	>=xfce-extra/tumbler-4.16.0
	!minimal? (
		media-fonts/dejavu
		virtual/freedesktop-icon-theme
		)
	svg? ( gnome-base/librsvg )
	upower? ( >=xfce-extra/xfce4-power-manager-4.16.0 )"
