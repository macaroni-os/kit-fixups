# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit eutils

DESCRIPTION="A highly configurable replacement for syslogd/klogd"
HOMEPAGE="https://github.com/hvisage/metalog"
SRC_URI="${HOMEPAGE}/archive/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="unicode"

RDEPEND=">=dev-libs/libpcre-3.4"
DEPEND="${RDEPEND}
	sys-devel/autoconf-archive
	virtual/pkgconfig
	app-arch/xz-utils"

PATCHES=( "${FILESDIR}"/${PN}-0.9-metalog-conf.patch )

S=${WORKDIR}/${PN}-${P}

src_configure() {
	chmod +x autogen.sh
	./autogen.sh || die "autogen failed"
	econf $(use_with unicode)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog README NEWS metalog.conf

	into /
	dosbin "${FILESDIR}"/consolelog.sh

	newinitd "${FILESDIR}"/metalog.initd metalog
	newconfd "${FILESDIR}"/metalog.confd metalog
}

pkg_preinst() {
	if [[ -d "${ROOT}"/etc/metalog ]] && [[ ! -e "${ROOT}"/etc/metalog.conf ]] ; then
		mv -f "${ROOT}"/etc/metalog/metalog.conf "${ROOT}"/etc/metalog.conf
		rmdir "${ROOT}"/etc/metalog
		export MOVED_METALOG_CONF=true
	else
		export MOVED_METALOG_CONF=false
	fi
}

pkg_postinst() {
	if ${MOVED_METALOG_CONF} ; then
		ewarn "The default metalog.conf file has been moved"
		ewarn "from /etc/metalog/metalog.conf to just"
		ewarn "/etc/metalog.conf.  If you had a standard"
		ewarn "setup, the file has been moved for you."
	fi
}
