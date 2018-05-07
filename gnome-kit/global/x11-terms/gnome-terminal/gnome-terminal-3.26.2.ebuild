# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2 readme.gentoo-r1

DESCRIPTION="The Gnome Terminal"
HOMEPAGE="https://wiki.gnome.org/Apps/Terminal/"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="debug +deprecated-transparency +gnome-shell +nautilus vanilla-hotkeys"

# FIXME: automagic dependency on gtk+[X], just transitive but needs proper control
RDEPEND="
	>=dev-libs/glib-2.42:2[dbus]
	>=x11-libs/gtk+-3.20:3[X]
	>=x11-libs/vte-0.50.2:2.91
	>=dev-libs/libpcre2-10
	>=gnome-base/dconf-0.14
	>=gnome-base/gsettings-desktop-schemas-0.1.0
	sys-apps/util-linux
	gnome-shell? ( gnome-base/gnome-shell )
	nautilus? ( >=gnome-base/nautilus-3 )
"
# itstool required for help/* with non-en LINGUAS, see bug #549358
# xmllint required for glib-compile-resources, see bug #549304
DEPEND="${RDEPEND}
	app-text/yelp-tools
	dev-libs/libxml2
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
"

DOC_CONTENTS="To get previous working directory inherited in new opened
	tab you will need to add the following line to your ~/.bashrc:\n
	. /etc/profile.d/vte-2.91.sh"

src_prepare() {
	if use deprecated-transparency; then
		# From Fedora:
		# 	http://pkgs.fedoraproject.org/cgit/rpms/gnome-terminal.git/tree/?h=f27
		eapply "${FILESDIR}"/${PN}-3.18.2-build-dont-treat-warnings-as-errors.patch
		eapply "${FILESDIR}"/${PN}-3.26.2-transparency.patch

		# From GNOME:
		# 	https://git.gnome.org/browse/gnome-terminal/commit/?id=b3c270b3612acd45f309521cf1167e1abd561c09
		eapply "${FILESDIR}"/${PN}-3.14.3-fix-broken-transparency-on-startup.patch
	fi

	if ! use vanilla-hotkeys; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1652
		eapply "${FILESDIR}"/${PN}-3.16.2-disable-function-keys.patch
	fi

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--disable-migration \
		$(use_enable debug) \
		$(use_enable gnome-shell search-provider) \
		$(use_with nautilus nautilus-extension) \
		VALAC=$(type -P true)
}

src_install() {
	gnome2_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst
	readme.gentoo_print_elog
}
