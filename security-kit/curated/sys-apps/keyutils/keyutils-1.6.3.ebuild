EAPI=7

inherit toolchain-funcs linux-info usr-ldscript

DESCRIPTION="Linux Key Management Utilities"
HOMEPAGE="https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git"
SRC_URI="https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0/1.10"
KEYWORDS="*"
IUSE="static static-libs"
RESTRICT="test"

RDEPEND=""
DEPEND="!prefix? ( >=sys-kernel/linux-headers-2.6.11 )"

PATCHES=(
	"${FILESDIR}"/${PN}-1.6-makefile-fixup.patch
	"${FILESDIR}"/${PN}-1.5.10-disable-tests.patch #519062 #522050
	"${FILESDIR}"/${PN}-1.5.9-header-extern-c.patch
	"${FILESDIR}"/${PN}-1.6.3-fix-rpmspec-check.patch
)

pkg_setup() {
	CONFIG_CHECK="~KEYS"
	ERROR_KEYS="You will be unable to use this package on this system because CONFIG_KEYS is not set!"

	if kernel_is -ge 4 7 ; then
		CONFIG_CHECK="${CONFIG_CHECK} ~KEY_DH_OPERATIONS"
		ERROR_KEY_DH_OPERATIONS="You will be unable to use Diffie-Hellman on this system because CONFIG_KEY_DH_OPERATIONS is not set!"
	fi

	linux-info_pkg_setup
}

src_prepare() {
	default

	# The lsb check is useless, so avoid spurious command not found messages.
	sed -i -e 's,lsb_release,:,' tests/prepare.inc.sh || die

}

src_compile() {
	tc-export AR CC CXX
	sed -i \
		-e "1iRPATH = $(usex static -static '')" \
		-e '/^C.*FLAGS/s|:=|+=|' \
		-e 's:-Werror::' \
		-e '/^BUILDFOR/s:=.*:=:' \
		-e "/^LIBDIR/s:=.*:= /usr/$(get_libdir):" \
		-e '/^USRLIBDIR/s:=.*:=$(LIBDIR):' \
		-e "s: /: ${EPREFIX}/:g" \
		-e '/^NO_ARLIB/d' \
		Makefile || die

	# We need the static lib in order to statically link programs.
	if use static ; then
		export NO_ARLIB=0
		# Hack the progs to depend on the static lib instead.
		sed -i \
			-e '/^.*:.*[$](DEVELLIB)$/s:$(DEVELLIB):$(ARLIB) $(SONAME):' \
			Makefile || die
	else
		export NO_ARLIB=$(usex static-libs 0 1)
	fi
	emake
}

src_install() {
	# Possibly undo the setting for USE=static (see src_compile).
	export NO_ARLIB=$(usex static-libs 0 1)

	default
	use static || gen_usr_ldscript -a keyutils

	dodoc README
}
