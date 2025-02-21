# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Adobe's open source typeface family designed for UI environments"
HOMEPAGE="
    https://adobe-fonts.github.io/source-sans-pro/
	https://adobe-fonts.github.io/source-serif-pro/
	https://adobe-fonts.github.io/source-code-pro/
"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="*"
IUSE="cjk"

RDEPEND="
    media-libs/fontconfig
    media-fonts/source-code-pro
    media-fonts/source-sans
    media-fonts/source-serif
	cjk? ( media-fonts/source-han-sans )
"

