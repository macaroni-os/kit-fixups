# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.24"

inherit autotools eutils gnome2 vala git-r3

DESCRIPTION="Terminal emulator widget"
HOMEPAGE="https://github.com/thestinger/vte-ng"

# SRC_URI="https://github.com/thestinger/${PN}/archive/${PV}-ng.zip"
SRC_URI=""
EGIT_REPO_URI="https://github.com/thestinger/vte-ng.git"
EGIT_BRANCH="${PV%%.9999}-ng"

LICENSE="LGPL-2+"
SLOT="2.91"
IUSE="+crypt debug glade +introspection vala"
KEYWORDS=""
REQUIRED_USE="vala? ( introspection )"

PDEPEND=""
RDEPEND="
	>=dev-libs/glib-2.40:2
	>=dev-libs/libpcre2-10.21
	>=x11-libs/gtk+-3.8:3[introspection?]
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses:0=
	sys-libs/zlib

	crypt?  ( >=net-libs/gnutls-3.2.7:0= )
	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0:= )
"

DEPEND="${RDEPEND}
	dev-libs/libxml2
	>=dev-util/gtk-doc-1
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig

	vala? ( $(vala_depend) )
"

RDEPEND="
	${RDEPEND}
	!x11-libs/vte:2.90[glade]
	!x11-libs/vte:2.91
"

S="${WORKDIR}/vte-ng-${PV}"

src_prepare() {
	use vala && vala_src_prepare

	# build fails because of -Werror with gcc-5.x
	# sed -e 's#-Werror=format=2#-Wformat=2#' -i configure.ac || die "sed failed"
	# sed -e 's#\(-Wno-missing-field-initializers dnl\)#\1\n  -Wno-unused-function dnl#' -i configure.ac || die "sed failed"
	sed -e '#-Werror.*$\)#d' -i configure.ac || die "sed failed"

	gnome2_src_prepare
}

src_configure() {
	local myconf=""

	if [[ ${CHOST} == *-interix* ]]; then
		myconf="${myconf} --disable-Bsymbolic"

		# interix stropts.h is empty...
		export ac_cv_header_stropts_h=no
	fi

	# Python bindings are via gobject-introspection
	# Ex: from gi.repository import Vte
	gtkdocize --copy --flavour no-tmpl || die
	autoreconf --force --install --verbose || die
	intltoolize --force || die
	gnome2_src_configure \
		--disable-deprecation \
		--disable-test-application \
		--disable-static \
		$(use_enable debug) \
		$(use_enable glade glade-catalogue) \
		$(use_with crypt gnutls) \
		$(use_enable introspection) \
		$(use_enable vala) \
		${myconf}
}

src_install() {
	gnome2_src_install
	mv "${D}"/etc/profile.d/vte{,-${SLOT}}.sh || die
}
