# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

EGIT_REPO_URI="https://github.com/funtoo/keychain"
EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"
EGIT_BRANCH="devel"


DESCRIPTION="manage ssh and GPG keys in a convenient and secure manner. Frontend for ssh-agent/ssh-add"
HOMEPAGE="http://www.funtoo.org/Keychain"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="app-shells/bash || ( net-misc/openssh net-misc/ssh )"


src_install() {
	dobin keychain || die "dobin failed"
	doman keychain.1 || die "doman failed"
	dodoc ChangeLog README.md || die
}

pkg_postinst() {
	einfo "Please see the keychain man page or visit"
	einfo "$HOMEPAGE"
	einfo "for information on how to use keychain."
}
