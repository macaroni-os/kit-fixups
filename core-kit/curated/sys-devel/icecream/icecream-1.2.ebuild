# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils user autotools

DESCRIPTION="Distributed compiling of C(++) code across several machines; based on distcc"
HOMEPAGE="https://github.com/icecc/icecream"
SRC_URI="https://github.com/icecc/icecream/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sys-libs/libcap-ng
	dev-libs/lzo
	app-text/docbook2X
"
RDEPEND="
	${DEPEND}
	dev-util/shadowman
"

pkg_setup() {
	enewgroup icecream
	enewuser icecream -1 -1 /var/cache/icecream icecream
}

src_prepare() {
	eapply_user
	eautoreconf
}

src_configure() {
	econf \
		--enable-shared --disable-static \
		--enable-clang-wrappers \
		--enable-clang-rewrite-includes
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die

	newconfd suse/sysconfig.icecream icecream
	newinitd "${FILESDIR}"/icecream-r2 icecream

	insinto /etc/logrotate.d
	newins suse/logrotate icecream

	insinto /usr/share/shadowman/tools
	newins - icecc <<<'/usr/libexec/icecc/bin'
}

pkg_prerm() {
	if [[ -z ${REPLACED_BY_VERSION} && ${ROOT} == / ]]; then
		eselect compiler-shadow remove icecc
	fi
}

pkg_postinst() {
	if [[ ${ROOT} == / ]]; then
		eselect compiler-shadow update icecc
	fi
}
