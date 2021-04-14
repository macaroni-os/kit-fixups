# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="A fake root environment by means of LD_PRELOAD and SysV IPC (or TCP) trickery"
HOMEPAGE="https://packages.qa.debian.org/f/fakeroot.html"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${P/-/_}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="acl debug test"
RESTRICT="!test? ( test )"

DEPEND="
	sys-libs/libcap
	acl? ( sys-apps/acl )
	test? ( app-arch/sharutils )"
BDEPEND="app-text/po4a"

DOCS=( AUTHORS BUGS DEBUG README doc/README.saving )

PATCHES=(
	"${FILESDIR}/${PN}-define-_STAT_VER-if-not-already-define.patch"
	"${FILESDIR}/${PN}-add-wrappers-for-new-glibc-2.33-symbol.patch"
	"${FILESDIR}/${PN}-fix-compile-error-with-DEBUG-enabled.patch"
	"${FILESDIR}/${PN}-configure.ac-fix-__xmknod-at-pointer-argument.patch"
	"${FILESDIR}/${PN}-fix-fts_read-and-fts_children.patch"
	"${FILESDIR}/${PN}-OS-X-portability.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	export ac_cv_header_sys_acl_h=$(usex acl)
	use acl || export ac_cv_search_acl_get_fd=no # bug 759568
	use debug && append-cppflags -DLIBFAKEROOT_DEBUGGING

	econf --disable-static
}

src_compile() {
	# Create translated man pages
	pushd doc >/dev/null || die
	po4a -v -k 0 --variable "srcdir=${S}/doc/" po4a/po4a.cfg || die
	popd >/dev/null || die

	default
}

src_install() {
	default

	# no static archives
	find "${ED}" -name '*.la' -delete || die
}

