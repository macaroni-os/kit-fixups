# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font

DESCRIPTION="A free and open-source typeface for developers"
HOMEPAGE="https://www.jetbrains.com/lp/mono/"
SRC_URI="https://download.jetbrains.com/fonts/JetBrainsMono-${PV}.zip -> ${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

BDEPEND="app-arch/unzip"

S="${WORKDIR}"

FONT_SUFFIX="ttf"
