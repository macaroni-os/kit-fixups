# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Network Audio System"
HOMEPAGE="https://radscan.com/nas.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="HPND MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc static-libs"

RDEPEND="
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXaw
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXpm
	x11-libs/libXt"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto"
BDEPEND="
	app-text/rman
	sys-devel/bison
	sys-devel/flex
	sys-devel/gcc
	x11-misc/gccmakedep
	riscv? ( x11-misc/xorg-cf-files )
	>=x11-misc/imake-1.0.8-r1"

DOCS=( BUILDNOTES FAQ HISTORY README RELEASE TODO )

PATCHES=(
	"${FILESDIR}/${PN}-1.9.2-asneeded.patch"
	"${FILESDIR}/${PN}-1.9.4-libfl.patch"
)

src_prepare() {
	default
}

src_configure() {
	# Need to run econf so that config.guess is updated
	pushd config || die
	econf
	popd || die

	local cpp=($(get_abi_CHOST ${DEFAULT_ABI})-gcc $(get_abi_CFLAGS) -E) #884203
	CC="$(tc-getBUILD_CC)" LD="$(tc-getLD)" \
		IMAKECPP="${IMAKECPP:-${cpp[*]}}" \
		xmkmf -a || die
}

src_compile() {
	# EXTRA_LDOPTIONS, SHLIBGLOBALSFLAGS #336564#c2
	local emakeopts=(
		AR="$(tc-getAR) cq"
		AS="$(tc-getAS)"
		CC="$(tc-getCC)"
		CDEBUGFLAGS="${CFLAGS}"
		CXX="$(tc-getCXX)"
		CXXDEBUFLAGS="${CXXFLAGS}"
		EXTRA_LDOPTIONS="${LDFLAGS}"
		LD="$(tc-getLD)"
		MAKE="${MAKE:-gmake}"
		RANLIB="$(tc-getRANLIB)"
		SHLIBGLOBALSFLAGS="${LDFLAGS}"
		WORLDOPTS=
	)

		sed -i \
			-e 's/SUBDIRS =.*/SUBDIRS = include lib config/' \
			Makefile || die

	emake "${emakeopts[@]}"
}

src_install() {
	# ranlib is used at install phase too wrt #446600
	emake RANLIB="$(tc-getRANLIB)" \
		DESTDIR="${D}" USRLIBDIR=/usr/$(get_libdir) \
		install install.man

	einstalldocs
	if use doc; then
		docinto doc
		dodoc doc/{actions,protocol.txt,README}
		docinto pdf
		dodoc doc/pdf/*.pdf
	fi

	newconfd "${FILESDIR}"/nas.conf.d nas
	newinitd "${FILESDIR}"/nas.init.d nas

	if ! use static-libs; then
		rm -f "${D}"/usr/lib*/libaudio.a || die
	fi
}
