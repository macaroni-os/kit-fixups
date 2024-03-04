# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Bootstrap package for dev-lang/go"
HOMEPAGE="https://golang.org"
BOOTSTRAP_DIST="https://dev.gentoo.org/~williamh/dist"
SRC_URI="
	amd64? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-amd64-bootstrap.tbz )
	arm? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-arm-bootstrap.tbz )
	arm64? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-arm64-bootstrap.tbz )
	mips? (
		abi_mips_o32? (
			big-endian? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-mips-bootstrap.tbz )
			!big-endian? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-mipsle-bootstrap.tbz )
		)
		abi_mips_n64? (
			big-endian? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-mips64-bootstrap.tbz )
			!big-endian? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-mips64le-bootstrap.tbz )
		)
	)
	ppc64? (
		big-endian? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-ppc64-bootstrap.tbz )
		!big-endian? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-ppc64le-bootstrap.tbz )
	)
	riscv? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-riscv64-bootstrap.tbz )
	s390? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-s390x-bootstrap.tbz )
	x86? ( ${BOOTSTRAP_DIST}/go-${PV}-linux-386-bootstrap.tbz )
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm ~arm64 ~mips ~ppc64 ~riscv ~s390 ~x86 ~amd64-linux ~x86-linux"
IUSE="abi_mips_n64 abi_mips_o32 big-endian"
RESTRICT="strip"
QA_PREBUILT="*"

S="${WORKDIR}"

src_install() {
	dodir /usr/lib
	mv go-*-bootstrap "${ED}/usr/lib/go-bootstrap" || die

	# testdata directories are not needed on the installed system
	rm -fr $(find "${ED}"/usr/lib/go-bootstrap -iname testdata -type d -print)
}
