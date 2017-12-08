# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4..6} )

inherit python-single-r1

DESCRIPTION="Funtoo's configuration tool: ego, epro, edoc."
HOMEPAGE="http://www.funtoo.org/Package:Ego"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="zsh-completion"
RESTRICT="mirror"
GITHUB_REPO="$PN"
GITHUB_USER="funtoo"
GITHUB_TAG="${PV}"
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

# FL-4450.  below patch is a git head backport to fix the parent problem. prepare phase need removed with new ego tag release. GITHUB_TAG need change back then, as well
src_prepare() {
	pushd "${S}" &>/dev/null
	eapply "${FILESDIR}"/${PN}-2.3.3-parent.patch
	popd &>/dev/null
	default
}

src_install() {
	exeinto /usr/share/ego/modules
	doexe $S/modules/*.ego
	insinto /usr/share/ego/modules-info
	doins $S/modules-info/*
	insinto /usr/share/ego/python
	doins -r $S/python/*
	rm -rf $D/usr/share/ego/python/test
	dobin $S/ego
	dosym ego /usr/bin/epro
	dosym ego /usr/bin/edoc
	doman doc/*.[1-8]
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

	# Temporary fix due to older versions of ego setting some root ownerships
	# under /var/git/meta-repo. This fix was introduced in version 2.0.13 and
	# can be removed in January 2018 when we can assume it was applied to the
	# vast majority of Funtoo stations.
	chown -R portage:portage $ROOT/var/git/meta-repo
}
