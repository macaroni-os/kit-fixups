# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit python-single-r1

DESCRIPTION="Funtoo's and MARK configuration tool: ego, epro, edoc, boot-update"
HOMEPAGE="https://github.com/macaroni-os/ego"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="zsh-completion"
SRC_URI="https://github.com/macaroni-os/ego/archive/ddfcfe117be24c95f21f72901c252ceefa3205d7.zip -> ego-2.8.8_pre20240817-ddfcfe1.zip"

DEPEND=""
RDEPEND="$PYTHON_DEPS !sys-boot/boot-update !<sys-kernel/linux-firmware-20220209-r1"
PDEPEND=">=dev-python/appi-0.2[${PYTHON_USEDEP}]
dev-python/mwparserfromhell[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${PN}"-* "${S}" || die
}

src_install() {
	exeinto /usr/share/ego/modules
	doexe $S/modules/*.ego
	rm $D/usr/share/ego/modules/upgrade*
	insinto /usr/share/ego/modules-info
	doins $S/modules-info/*
	rm $D/usr/share/ego/modules-info/upgrade*
	insinto /usr/share/ego/python
	doins -r $S/python/*
	rm -rf $D/usr/share/ego/python/test
	dobin $S/ego
	dosym ego /usr/bin/epro
	dosym ego /usr/bin/edoc
	dosym /usr/bin/ego /sbin/boot-update
	doman doc/*.[1-8]
	dodoc doc/*.rst
	insinto /etc
	doins $S/etc/*.conf*
	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/completion/zsh/_ego
	fi
}

pkg_postinst() {
	if [ ! -e $ROOT/etc/boot.conf ]; then
		einfo "Installing default /etc/boot.conf file..."
		cp -f $ROOT/etc/boot.conf.dist $ROOT/etc/boot.conf
	fi
	if [ -e $ROOT/usr/share/portage/config/repos.conf ]; then
		rm -f $ROOT/usr/share/portage/config/repos.conf
	fi
	[ -h $ROOT/usr/sbin/epro ] && rm $ROOT/usr/sbin/epro
	if [ "$ROOT" = "/" ]; then
		/usr/bin/ego sync --in-place
	fi
}