# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools libtool

DESCRIPTION="Raqm is a small library that encapsulates \
    the logic for complex text layout and provides a \
    convenient API."

HOMEPAGE="https://host-oman.github.io/libraqm/"
SRC_URI="https://github.com/HOST-Oman/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"

IUSE="test gtk-doc"

RDEPEND="media-libs/freetype
    media-libs/harfbuzz
    dev-libs/fribidi
    gtk-doc? ( dev-util/gtk-doc )"

DEPEND="${RDEPEND}"

src_prepare() {
    default
    ./autogen.sh || die "autogen failed"
    elibtoolize --patch-only
}

src_configure() {
    # NOTE: gtk-doc-pdf flag disabled
    # depends on fop(java) or dblatex(py2.7 only)
    econf \
        --prefix="${EPREFIX}/usr" \
        --enable-static=no \
        --enable-shared=yes \
        --enable-fast-install=yes \
        $(use_enable gtk-doc) \
        $(use_enable gtk-doc gtk-doc-html) \
        --enable-gtk-doc-pdf=no
}

src_test() {
    if use test; then
        emake check
    fi
}

src_install() {
    emake DESTDIR="${D}" install
    pushd "${BUILD_DIR}" >/dev/null || die
    dodoc README AUTHORS NEWS
    insinto "${DESTDIR}/usr/lib64/pkgconfig"
    doins raqm.pc
    if use gtk-doc; then
        einstalldocs
    fi
    popd >/dev/null || die
}
