EAPI="7"

DESCRIPTION="Scripts to build livecd Funtoo"
HOMEPAGE="https://funtoo.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_compile() {
	einfo "Nothing to compile, install scripts only"
}

S="${WORKDIR}"

src_install() {
	dobin "${FILESDIR}/bashlogin"
	dobin "${FILESDIR}/bashlogin-banner" || die
	insinto /etc
	doins "${FILESDIR}/funtoo.ascii"
	doins "${FILESDIR}/funtoo_small.ascii"
}
