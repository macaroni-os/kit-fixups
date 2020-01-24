# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-minimal autotools
MY_PN="gc"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Boehm-Demers-Weiser conservative garbage collector for C and C++."
HOMEPAGE="http://www.hboehm.info/gc"
SRC_URI="https://github.com/ivmai/bdwgc/releases/download/v${PV}/${MY_P}.tar.gz"

LICENSE="boehm-gc"
SLOT="0/7"
KEYWORDS="*"
IUSE="+cxx +static-libs +threads"

DEPEND="virtual/pkgconfig >=dev-libs/libatomic_ops-7.6[${MULTILIB_USEDEP}]"
RDEPEND=">=dev-libs/libatomic_ops-7.6[${MULTILIB_USEDEP}]"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	local myconf=(
		--with-libatomic-ops=yes
		--disable-docs
		$(use_enable cxx cplusplus)
		$(use_enable static-libs static)
		$(use threads || printf -- "--enable-threads=single")
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install_all() {
	# package provides .pc files
	find "${ED}" -name '*.la' -delete || die

	# Install docs and man page
	local HTML_DOCS=( doc/*.html )
	local DOCS=( doc/README{.environment,.linux,.macros} )
	einstalldocs
	newman doc/gc.man GC_malloc.3
	for a in GC_{malloc_atomic,free,realloc,enable_incremental,register_finalizer,malloc_ignore_off_page,malloc_atomic_ignore_off_page,set_warn_proc} ; do
		dosym "GC_malloc.3" "${EPREFIX}/usr/share/man/man3/${a}.3"
	done
}
