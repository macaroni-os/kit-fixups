# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 gnome3-utils meson

DESCRIPTION="A simple GTK+ frontend for mpv"
HOMEPAGE="https://github.com/celluloid-player/celluloid"

GITHUB_REPO="celluloid-player"
GITHUB_USER="celluloid"
GITHUB_TAG="$P"
SRC_URI="https://github.com/${GITHUB_REPO}/${GITHUB_USER}/archive/v${PV}.tar.gz -> ${GITHUB_TAG}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
RDEPEND="
	>=dev-libs/glib-2.44
	media-libs/libepoxy
	>=media-video/mpv-0.27[libmpv]
	>=x11-libs/gtk+-3.22.23:3
"

src_prepare() {
	# drop unnecessary cflags/ldflags
	sed -i \
		-e "s/if cc.has_multi_arguments.*/if false/" \
		-e "s/if cc.has_argument.*/if false/" \
		meson.build || die

	default
}
