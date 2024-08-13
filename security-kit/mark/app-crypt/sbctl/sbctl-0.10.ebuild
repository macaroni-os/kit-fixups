# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

DESCRIPTION="Secure Boot key manager"
HOMEPAGE="https://github.com/Foxboron/sbctl"
SRC_URI="https://github.com/Foxboron/${PN}/releases/download/${PV}/${P}.tar.gz
	https://area31.host.funtoo.org/distfiles/${P}-deps.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="*"

BDEPEND="app-text/asciidoc"

src_unpack() {
	default
}

src_install() {
	emake PREFIX="${ED}/usr" install
}
