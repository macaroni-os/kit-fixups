# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PLOCALES="de fr ja pt_BR tr uk zh_CN"

inherit fcaps flag-o-matic meson plocale systemd toolchain-funcs

SRC_URI="https://github.com/iputils/iputils/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://dev.gentoo.org/~whissi/dist/iputils/${PN}-manpages-${PV}.tar.xz"
KEYWORDS="*"

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="https://wiki.linuxfoundation.org/networking/iputils"

LICENSE="BSD GPL-2+ rdisc"
SLOT="0"
IUSE="+arping caps clockdiff doc gcrypt idn ipv6 nettle nls rarpd rdisc ssl static test tftpd tracepath traceroute6"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	test? ( sys-apps/iproute2 )
	nls? ( sys-devel/gettext )
"

LIB_DEPEND="
	caps? ( sys-libs/libcap[static-libs(+)] )
	idn? ( net-dns/libidn2:=[static-libs(+)] )
	nls? ( virtual/libintl[static-libs(+)] )
"

RDEPEND="
	traceroute6? ( !net-analyzer/traceroute )
	!static? ( ${LIB_DEPEND//\[static-libs(+)]} )
"

DEPEND="
	${RDEPEND}
	virtual/os-headers
	static? ( ${LIB_DEPEND} )
"

PATCHES=(
	# Upstream; drop on bump
	"${FILESDIR}"/${P}-optional-tests.patch
)

src_prepare() {
	default

	plocale_get_locales > po/LINGUAS || die
}

src_configure() {
	use static && append-ldflags -static

	local emesonargs=(
		-DUSE_CAP="$(usex caps true false)"
		-DUSE_IDN="$(usex idn true false)"
		-DBUILD_ARPING="$(usex arping true false)"
		-DBUILD_CLOCKDIFF="$(usex clockdiff true false)"
		-DBUILD_PING="true"
		-DBUILD_RARPD="$(usex rarpd true false)"
		-DBUILD_RDISC="$(usex rdisc true false)"
		-DENABLE_RDISC_SERVER="$(usex rdisc true false)"
		-DBUILD_TFTPD="$(usex tftpd true false)"
		-DBUILD_TRACEPATH="$(usex tracepath true false)"
		-DBUILD_TRACEROUTE6="$(usex ipv6 $(usex traceroute6 true false) false)"
		-DBUILD_NINFOD="false"
		-DNINFOD_MESSAGES="false"
		-DNO_SETCAP_OR_SUID="true"
		-Dsystemdunitdir="$(systemd_get_systemunitdir)"
		-DUSE_GETTEXT="$(usex nls true false)"
		$(meson_use !test SKIP_TESTS)
	)

	emesonargs+=(
		-DBUILD_HTML_MANS="false"
		-DBUILD_MANS="false"
	)

	meson_src_configure
}

src_compile() {
	tc-export CC
	meson_src_compile
}

src_test() {
	if [[ ${EUID} != 0 ]]; then
		einfo "Tests require root privileges; Skipping ..."
		return
	fi

	meson_src_test
}

src_install() {
	meson_src_install

	dodir /bin
	local my_bin
	for my_bin in $(usex arping arping '') ping ; do
		mv "${ED}"/usr/bin/${my_bin} "${ED}"/bin/ || die
	done
	dosym ping /bin/ping4

	if use tracepath ; then
		dosym tracepath /usr/bin/tracepath4
	fi

	if use ipv6 ; then
		dosym ping /bin/ping6

		if use tracepath ; then
			dosym tracepath /usr/bin/tracepath6
			dosym tracepath.8 /usr/share/man/man8/tracepath6.8
		fi
	fi

	local -a man_pages
	local -a html_man_pages

	while IFS= read -r -u 3 -d $'\0' my_bin
	do
		my_bin=$(basename "${my_bin}")
		[[ -z "${my_bin}" ]] && continue

		if [[ -f "${S}/doc/${my_bin}.8" ]] ; then
			man_pages+=( ${my_bin}.8 )
		fi

		if [[ -f "${S}/doc/${my_bin}.html" ]] ; then
			html_man_pages+=( ${my_bin}.html )
		fi
	done 3< <(find "${ED}"/{bin,usr/bin,usr/sbin} -type f -perm -a+x -print0 2>/dev/null)

	pushd doc &>/dev/null || die
	doman "${man_pages[@]}"
	if use doc ; then
		docinto html
		dodoc "${html_man_pages[@]}"
	fi
	popd &>/dev/null || die
}

pkg_postinst() {
	fcaps cap_net_raw \
		bin/ping \
		$(usex arping 'bin/arping' '') \
		$(usex clockdiff 'usr/bin/clockdiff' '')
}
