# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A Funtoo-ized meta package for split proto xorg ebuilds" # FL-4990.
HOMEPAGE="https://www.x.org/wiki/"

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	=x11-proto/xf86rushproto-1.1.2-r1
	=x11-proto/dri3proto-1.0
	=x11-proto/fixesproto-5.0-r1
	=x11-proto/xf86driproto-2.1.1-r1
	=x11-proto/xcmiscproto-1.2.2
	=x11-proto/xf86vidmodeproto-2.3.1-r1
	=x11-proto/trapproto-3.4.3
	=x11-proto/dri2proto-2.8-r1
	=x11-proto/recordproto-1.14.2-r1
	=x11-proto/videoproto-2.3.3
	=x11-proto/inputproto-2.3.2
	=x11-proto/xf86dgaproto-2.1-r2
	=x11-proto/presentproto-1.1
	=x11-proto/kbproto-1.0.7
	=x11-proto/compositeproto-0.4.2-r1
	=x11-proto/resourceproto-1.2.0
	=x11-proto/fontsproto-2.1.3
	=x11-proto/glproto-1.4.17-r1
	=x11-proto/xineramaproto-1.2.1-r1
	=x11-proto/damageproto-1.2.1-r1
	=x11-proto/xextproto-7.3.0
	=x11-proto/bigreqsproto-1.1.2
	=x11-proto/xproto-7.0.31
	=x11-proto/renderproto-0.11.1-r1
	=x11-proto/scrnsaverproto-1.2.2-r1
	=x11-proto/xf86bigfontproto-1.2.0-r1
	=x11-proto/randrproto-1.5.0
"
