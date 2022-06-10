# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils multilib autotools multilib-minimal

DESCRIPTION="A ELF object file access library"
HOMEPAGE="https://web.archive.org/web/20181111033959/http://www.mr511.de/software/english.html"
SRC_URI="https://web.archive.org/web/20181111033959/http://www.mr511.de/software/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug nls elibc_FreeBSD"

RDEPEND="!dev-libs/elfutils"
DEPEND="nls? ( sys-devel/gettext )"

DOCS=( ChangeLog README )
MULTILIB_WRAPPED_HEADERS=( /usr/include/libelf/sys_elf.h )

src_prepare() {
	eapply "${FILESDIR}/${P}-build.patch"
	eapply_user
	eautoreconf
}

multilib_src_configure() {
	# prefix might want to play with this; unfortunately the stupid
	# macro used to detect whether we're building ELF is so screwed up
	# that trying to fix it is just a waste of time.
	export mr_cv_target_elf=yes

	ECONF_SOURCE="${S}" econf \
		$(use_enable nls) \
		--enable-shared \
		$(use_enable debug)
}

multilib_src_install() {
	emake \
		prefix="${ED}usr" \
		libdir="${ED}usr/$(get_libdir)" \
		install \
		install-compat \
		-j1 || die

	# Stop libelf from stamping on the system nlist.h
	use elibc_FreeBSD && rm "${ED}"/usr/include/nlist.h
}
