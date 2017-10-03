# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python3_{4,5,6} )

inherit python-single-r1

DESCRIPTION="Funtoo's configuration tool: ego, epro, edoc."
HOMEPAGE="http://www.funtoo.org/Package:Ego"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="zsh-completion"
RESTRICT="mirror"
GITHUB_REPO="$PN"
GITHUB_USER="funtoo"
GITHUB_TAG="${PVR}"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

DEPEND=""
RDEPEND="$PYTHON_DEPS
dev-python/appi:0/0.1[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]
dev-python/mwparserfromhell[${PYTHON_USEDEP}]"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${PN}"-??????? "${S}" || die
}

src_install() {
	exeinto /usr/share/ego/modules
	doexe $S/modules/*.ego
	insinto /usr/share/ego/modules-info
	doins $S/modules-info/*
	insinto /usr/share/ego/python
	doins $S/python/*.py
	dobin $S/ego
	dosym ego /usr/bin/epro
	dosym ego /usr/bin/edoc
	doman ego.1 epro.1
	insinto /etc
	doins $FILESDIR/ego.conf
	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/completion/zsh/_ego
	fi
}

pkg_postinst() {
	if [ ! -e $ROOT/etc/portage/repos.conf ]; then
		ln -s /var/git/meta-repo/repos.conf $ROOT/etc/portage/repos.conf
	fi
	if [ -e $ROOT/usr/share/portage/config/repos.conf ]; then
		rm -f $ROOT/usr/share/portage/config/repos.conf
	fi
	[ -h $ROOT/usr/sbin/epro ] && rm $ROOT/usr/sbin/epro
	if [ "$ROOT" = "/" ]; then
	    /usr/bin/epro update
	fi
}
