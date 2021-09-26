# Distributed under the terms of the GNU General Public License v2

# emacs support disabled due to #99533 #335900

EAPI=7

inherit autotools linux-info systemd usr-ldscript

DESCRIPTION="Console-based mouse driver"
HOMEPAGE="http://www.nico.schottelius.org/software/gpm/"
SRC_URI="http://www.nico.schottelius.org/software/${PN}/archives/${P}.tar.lzma
	mirror://gentoo/${P}-docs.patch.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="selinux static-libs"

RDEPEND="selinux? ( sec-policy/selinux-gpm )"

# ncurses intentionally removed to avoid circular deps.
DEPEND="app-arch/xz-utils
	sys-apps/texinfo
	virtual/yacc"

src_prepare() {
	# QA-460: fix gcc inlude path, so it able to find own headers during build, like gpm.h.
	eapply "${FILESDIR}"/${P}-gcc-include-fix.patch
	eapply "${FILESDIR}"/${P}-sysmacros.patch #fix build on newer glibc
	eapply "${FILESDIR}"/${P}-glibc-2.26.patch #fix build specifically with glibc-2.26
	eapply "${FILESDIR}"/${P}-gcc-10.patch
	eapply "${WORKDIR}"/${P}-docs.patch
	touch -r . doc/* || die
	eapply_user

	# fix ABI values
	sed -i \
		-e '/^abi_lev=/s:=.*:=1:' \
		-e '/^abi_age=/s:=.*:=20:' \
		configure.ac.footer || die
	sed -i -e '/ACLOCAL/,$d' autogen.sh || die
	./autogen.sh
	eautoreconf
}

src_configure() {
	econf \
		--without-curses \
		--sysconfdir=/etc/gpm \
		$(use_enable static-libs static) \
		emacs=/bin/false
}

src_compile() {
	# make sure nothing compiled is left
	emake clean
	emake EMACS=:
}

src_install() {
	emake \
		DESTDIR="${D}" \
		EMACS=: ELISP="" \
		install

	dosym libgpm.so.1 /usr/$(get_libdir)/libgpm.so
	gen_usr_ldscript -a gpm
	insinto /etc/gpm
	doins conf/gpm-*.conf

	dodoc README TODO
	dodoc doc/Announce doc/FAQ doc/README*

	newinitd "${FILESDIR}"/gpm.rc6-2 gpm
	newconfd "${FILESDIR}"/gpm.conf.d gpm
	systemd_dounit "${FILESDIR}"/gpm.service
}
