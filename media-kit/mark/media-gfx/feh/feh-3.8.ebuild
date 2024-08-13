# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit toolchain-funcs xdg-utils

DESCRIPTION="A fast, lightweight imageviewer using imlib2"
HOMEPAGE="https://feh.finalrewind.org/"
SRC_URI="https://feh.finalrewind.org/${P}.tar.bz2"

LICENSE="feh"
SLOT="0"
KEYWORDS="*"
IUSE="debug curl exif test xinerama"

COMMON_DEPEND="media-libs/imlib2[X]
	>=media-libs/libpng-1.2:0=
	x11-libs/libX11
	curl? ( net-misc/curl )
	exif? ( media-libs/libexif )
	xinerama? ( x11-libs/libXinerama )"
RDEPEND="${COMMON_DEPEND}
	virtual/jpeg:0"
DEPEND="${COMMON_DEPEND}
	x11-libs/libXt
	x11-proto/xproto
	test? (
		>=dev-lang/perl-5.10
		dev-perl/Test-Command
	)"

pkg_setup() {
	fehopts=(
		DESTDIR="${D}"
		PREFIX="${EPREFIX}"/usr
		doc_dir='${main_dir}'/share/doc/${PF}
		example_dir='${main_dir}'/share/doc/${PF}/examples
		curl=$(usex curl 1 0)
		debug=$(usex debug 1 0)
		xinerama=$(usex xinerama 1 0)
		exif=$(usex exif 1 0)
	)
}

src_compile() {
	tc-export CC
	emake "${fehopts[@]}"
}

src_install() {
	emake "${fehopts[@]}" install
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
