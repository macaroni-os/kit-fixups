# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Bootstrap package for dev-lang/go"
HOMEPAGE="https://golang.org"
BOOTSTRAP_DIST="https://dl.google.com/go"
SRC_URI="
	amd64? ( ${BOOTSTRAP_DIST}/go${PV}.linux-amd64.tar.gz )
	arm?   ( ${BOOTSTRAP_DIST}/go${PV}.linux-armv6l.tar.gz )
	arm64? ( ${BOOTSTRAP_DIST}/go${PV}.linux-arm64.tar.gz )
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* amd64 arm arm64"
RESTRICT="strip"
QA_PREBUILT="*"

S="${WORKDIR}"

src_install() {
	dodir /usr/lib
	mv go "${ED}/usr/lib/go-bootstrap" || die
}
