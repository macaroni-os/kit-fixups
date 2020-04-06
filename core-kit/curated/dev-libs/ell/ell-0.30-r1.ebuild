# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic linux-info

DESCRIPTION="Embedded Linux Library provides core, low-level functionality for system daemons"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/libs/${PN}/${P}.tar.xz"
KEYWORDS="*"
LICENSE="LGPL-2.1"
SLOT="0"

IUSE="glib pie test"
RESTRICT="!test? ( test )"

RDEPEND="
	glib? ( dev-libs/glib:2 )
"

DEPEND="
	${RDEPEND}
	test? ( sys-apps/dbus )
"

CONFIG_CHECK="
	~TIMERFD
	~EVENTFD
	~CRYPTO_USER_API
	~CRYPTO_USER_API_HASH
	~CRYPTO_MD5
	~CRYPTO_SHA1
	~KEY_DH_OPERATIONS
"

src_prepare() {
	default
	[[ "${PV}" == *9999 ]] && eautoreconf
}

src_configure() {
	append-cflags "-fsigned-char" #662694
	local myeconfargs=(
		$(use_enable glib)
		$(use_enable pie)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_compile() {
	default
}

src_install() {
	default
	local DOCS=( ChangeLog README )
	einstalldocs
	find "${ED}" -name "*.la" -delete || die
}
