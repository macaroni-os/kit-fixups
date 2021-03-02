# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Efficient I/O with io_uring"
HOMEPAGE="https://github.com/axboe/liburing"
SRC_URI="https://git.kernel.dk/cgit/${PN}/snapshot/${P}.tar.bz2"
KEYWORDS="*"

LICENSE="MIT"
SLOT="0/1.0.7" # liburing.so version

IUSE="static-libs"
# fsync test hangs forever
RESTRICT="test"

src_prepare() {
	default
}

src_configure() {
	local myconf=(
		--prefix="${EPREFIX}/usr"
		--libdir="${EPREFIX}/usr/$(get_libdir)"
		--libdevdir="${EPREFIX}/usr/$(get_libdir)"
		--mandir="${EPREFIX}/usr/share/man"
		--cc="$(tc-getCC)"
	)
	# No autotools configure! "econf" will fail.
	TMPDIR="${T}" ./configure "${myconf[@]}"
}

src_compile() {
	emake V=1 AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)"
}

src_install_all() {
	einstalldocs

	if ! use static-libs ; then
		find "${ED}" -type f -name "*.a" -delete || die
	fi
}

src_test() {
	emake V=1 runtests
}
