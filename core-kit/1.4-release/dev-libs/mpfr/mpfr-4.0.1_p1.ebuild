# Distributed under the terms of the GNU General Public License v2

EAPI=6

# NOTE: we cannot depend on autotools here starting with gcc-4.3.x
inherit eutils libtool multilib-minimal

MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
PLEVEL=${PV/*p}
DESCRIPTION="library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="http://www.mpfr.org/"
SRC_URI="http://www.mpfr.org/mpfr-${MY_PV}/${MY_P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0/6" # libmpfr.so version
KEYWORDS="*"
IUSE="+static-libs"

RDEPEND=">=dev-libs/gmp-5.0.0[${MULTILIB_USEDEP},static-libs?]"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

HTML_DOCS=( doc/FAQ.html )

src_prepare() {
	if ! [ "${PLEVEL}" = "${PV}" ] ; then
		eapply "${FILESDIR}/${MY_P}_to_${MY_PV}-p${PLEVEL}.patch"
	fi
	eapply_user
	find . -type f -exec touch -r configure {} +
	elibtoolize
}

multilib_src_configure() {
	# Make sure mpfr doesn't go probing toolchains it shouldn't #476336#19
	ECONF_SOURCE=${S} \
	user_redefine_cc=yes \
	econf \
		--docdir="\$(datarootdir)/doc/${PF}" \
		$(use_enable static-libs static)
}

multilib_src_install_all() {
	rm "${ED}"/usr/share/doc/"${P}"/COPYING*
	use static-libs || find "${ED}"/usr -name '*.la' -delete
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libmpfr$(get_libname 4)
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libmpfr$(get_libname 4)
}
