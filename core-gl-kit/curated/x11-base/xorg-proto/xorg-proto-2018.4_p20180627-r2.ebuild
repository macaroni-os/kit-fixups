# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit meson multilib-minimal

DESCRIPTION="X.Org combined protocol headers"
HOMEPAGE="https://cgit.freedesktop.org/xorg/proto/xorgproto/"

GITHUB_REPO="xorg-xorgproto"
GITHUB_USER="freedesktop"
GITHUB_TAG="af9b5f43439378efd1e12d11d487a71f42790fec"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

LICENSE="GPL-2 MIT"
SLOT="0"

multilib_src_configure() {
	local emesonargs=(
		--datadir="${EPREFIX}/usr/share"
		-Dlegacy=false
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	DOCS=(
		AUTHORS
		PM_spec
		README
		$(set +f; echo COPYING-*)
		$(set +f; echo *.txt | grep -v meson.txt)
	)
	einstalldocs
}

PDEPEND="
	=x11-proto/evieproto-1.1.1*:0/stub
	=x11-proto/fontcacheproto-0.1.3*:0/stub
	=x11-proto/lg3dproto-5.0*:0/stub
	=x11-proto/printproto-1.0.5*:0/stub
	=x11-proto/xcalibrateproto-0.1.0*:0/stub
	=x11-proto/xf86rushproto-1.2.2*:0/stub
	=x11-proto/applewmproto-1.4.2*:0/stub
	=x11-proto/bigreqsproto-1.1.2*:0/stub
	=x11-proto/compositeproto-0.4.2*:0/stub
	=x11-proto/damageproto-1.2.1*:0/stub
	=x11-proto/dmxproto-2.3.1*:0/stub
	=x11-proto/dri2proto-2.8*:0/stub
	=x11-proto/dri3proto-1.2*:0/stub
	=x11-proto/fixesproto-5.0*:0/stub
	=x11-proto/fontsproto-2.1.3*:0/stub
	=x11-proto/glproto-1.4.17*:0/stub
	=x11-proto/inputproto-2.3.2*:0/stub
	=x11-proto/kbproto-1.0.7*:0/stub
	=x11-proto/presentproto-1.2*:0/stub
	=x11-proto/randrproto-1.6.0*:0/stub
	=x11-proto/recordproto-1.14.2*:0/stub
	=x11-proto/renderproto-0.11.1*:0/stub
	=x11-proto/resourceproto-1.2.0*:0/stub
	=x11-proto/scrnsaverproto-1.2.2*:0/stub
	=x11-proto/trapproto-3.4.3*:0/stub
	=x11-proto/videoproto-2.3.3*:0/stub
	=x11-proto/windowswmproto-1.0.4*:0/stub
	=x11-proto/xcmiscproto-1.2.2*:0/stub
	=x11-proto/xextproto-7.3.0*:0/stub
	=x11-proto/xf86bigfontproto-1.2.0*:0/stub
	=x11-proto/xf86dgaproto-2.1*:0/stub
	=x11-proto/xf86driproto-2.1.1*:0/stub
	=x11-proto/xf86miscproto-0.9.3*:0/stub
	=x11-proto/xf86vidmodeproto-2.3.1*:0/stub
	=x11-proto/xineramaproto-1.2.1*:0/stub
	=x11-proto/xproto-7.0.32*:0/stub
	=x11-proto/xproxymngproto-1.0.3*:0/stub"
