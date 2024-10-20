# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 vala

DESCRIPTION="A configuration management system for Xfce"
HOMEPAGE="https://www.xfce.org/projects/"
SRC_URI="https://archive.xfce.org/src/xfce/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0/3"
KEYWORDS="*"
IUSE="debug introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND=">=dev-libs/glib-2.50
	sys-apps/dbus
	>=xfce-base/libxfce4util-4.14:=
	introspection? ( dev-libs/gobject-introspection:= )
	!<xfce-base/xfce4-panel-4.13.1
	!<xfce-base/xfce4-settings-4.13.1"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	dev-util/glib-utils
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	vala? ( $(vala_depend) )"

src_prepare() {
	# stupid vala.eclass...
	default
}

src_configure() {
	local myconf=(
		$(use_enable introspection)
		$(use_enable vala)
		$(use_enable debug checks)
		--with-bash-completion-dir="$(get_bashcompdir)"
	)

	use vala && vala_src_prepare
	econf "${myconf[@]}"
}

src_test() {
	local service_dir=${HOME}/.local/share/dbus-1/services
	mkdir -p "${service_dir}" || die
	cat > "${service_dir}/org.xfce.Xfconf.service" <<-EOF || die
		[D-BUS Service]
		Name=org.xfce.Xfconf
		Exec=${S}/xfconfd/xfconfd
	EOF

	(
		# start isolated dbus session bus
		dbus_data=$(dbus-launch --sh-syntax) || exit
		eval "${dbus_data}"

		nonfatal emake check
		ret=${?}

		kill "${DBUS_SESSION_BUS_PID}"
		exit "${ret}"
	) || die
}

src_install() {
	default
	find "${D}" -type f -name '*.la' -delete || die
}
