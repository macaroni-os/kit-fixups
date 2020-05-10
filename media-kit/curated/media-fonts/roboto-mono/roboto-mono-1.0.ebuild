# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit font versionator xdg-utils

DESCRIPTION="Standard font for Android 4.0 (Ice Cream Sandwich) and later"
HOMEPAGE="https://fonts.google.com/speciman/Roboto+Mono"
# SRC_URI="https://github.com/google/${PN}/releases/download/v${PV}/roboto-unhinted.zip -> ${P}.zip"
SRC_URI="https://fonts.google.com/download?family=Roboto%20Mono -> ${P}.zip" 
FILENAME="/var/cache/portage/distfiles/${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

DEPEND="app-arch/unzip"

S=${WORKDIR}
FONT_S=${S}

FONT_SUFFIX="ttf"
FONT_CONF=( "${FILESDIR}"/90-roboto-mono.conf )

src_unpack() {
	unpack ${FILENAME}
}

src_install() {
	font_src_install
	# The license explicitly states that the license must be distributed with the
	# fonts. The only way to do that for the binpkg is to include it.
	dodoc LICENSE.txt
}
