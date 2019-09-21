# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=7

inherit autotools xdg

DESCRIPTION="Tool to read the contents of smartcards"
HOMEPAGE="http://pannetrat.com/Cardpeek"
SRC_URI="http://downloads.pannetrat.com/install/${P}.tar.gz"
# setting lua version used in package
LUA_VER="5.2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="libressl"

RDEPEND="sys-apps/pcsc-lite
	dev-lua/lua:${LUA_VER}
	x11-libs/gtk+:3
	net-misc/curl
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	export LUA_CFLAGS="-I/usr/include/lua${LUA_VER}"
	export LUA_LIBS="-llua${LUA_VER} -lm"

	default
}

pkg_postinst() {
	xdg_pkg_postinst
}
