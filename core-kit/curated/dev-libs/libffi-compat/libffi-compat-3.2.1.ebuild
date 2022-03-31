# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit libtool multilib-minimal

DESCRIPTION="a portable, high level programming interface to various calling conventions"
HOMEPAGE="https://sourceware.org/libffi/"
SRC_URI="ftp://sourceware.org/pub/libffi/libffi-${PV}.tar.gz"

LICENSE="MIT"
SLOT="6" # libffi.so.6
KEYWORDS="*"
IUSE="debug pax-kernel test"

RESTRICT="!test? ( test )"

RDEPEND="!dev-libs/libffi:0/0" # conflicts on libffi.so.6
DEPEND="test? ( dev-util/dejagnu )"

DOCS="ChangeLog* README"

PATCHES=(
	"${FILESDIR}"/libffi-3.2.1-o-tmpfile-eacces.patch #529044
	"${FILESDIR}"/libffi-3.2.1-include-path.patch
	"${FILESDIR}"/libffi-3.2.1-include-path-autogen.patch
)

S=${WORKDIR}/libffi-${PV}
ECONF_SOURCE=${S}

src_prepare() {
	default

	sed -i -e 's:@toolexeclibdir@:$(libdir):g' Makefile.in || die #462814
	elibtoolize
}

multilib_src_configure() {
	econf \
		--disable-static \
		$(use_enable pax-kernel pax_emutramp) \
		$(use_enable debug)
}

multilib_src_install() {
	dolib.so .libs/libffi.so.${SLOT}*
}
