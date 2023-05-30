# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Various tables for IBus-Table"
HOMEPAGE="https://github.com/moebiuscurve/ibus-table-others"
SRC_URI="https://github.com/moebiuscurve/ibus-table-others/releases/download/1.3.15/ibus-table-others-1.3.15.tar.gz -> ibus-table-others-1.3.15.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-i18n/ibus-table
	!app-i18n/ibus-table-code
	!app-i18n/ibus-table-cyrillic
	!app-i18n/ibus-table-latin
	!app-i18n/ibus-table-tv"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"