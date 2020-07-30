# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME_ORG_MODULE="NetworkManager"
GNOME2_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python3+ )

inherit bash-completion-r1 gnome3 linux-info python-any-r1 readme.gentoo-r1 vala virtualx udev user

DESCRIPTION="A set of co-operative tools that make networking simple and straightforward"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"

IUSE="audit bluetooth connection-sharing consolekit dhclient +dhcpcd elogind gnutls +introspection iwd json kernel_linux +nss +modemmanager ncurses ofono ovs policykit +ppp resolvconf selinux teamd test +vala +wext +wifi"
RESTRICT="!test? ( test )"

REQUIRED_USE="
	bluetooth? ( modemmanager )
	iwd? ( wifi )
	vala? ( introspection )
	wext? ( wifi )
	|| ( nss gnutls )
	?? ( consolekit elogind )
"

KEYWORDS="*"

# gobject-introspection-0.10.3 is needed due to gnome bug 642300
# wpa_supplicant-0.7.3-r3 is needed due to bug 359271
COMMON_DEPEND="
	>=dev-libs/glib-2.40:2
	policykit? ( >=sys-auth/polkit-0.106 )
	net-libs/libndp
	>=net-misc/curl-7.24
	net-misc/iputils
	sys-apps/util-linux
	sys-libs/readline:0=
	>=virtual/libudev-175:=
	audit? ( sys-process/audit )
	bluetooth? ( >=net-wireless/bluez-5 )
	connection-sharing? (
		net-dns/dnsmasq[dbus,dhcp]
		net-firewall/iptables )
	consolekit? ( >=sys-auth/consolekit-1.0.0 )
	dhclient? ( >=net-misc/dhcp-4[client] )
	dhcpcd? ( net-misc/dhcpcd )
	elogind? ( >=sys-auth/elogind-219 )
	introspection? ( >=dev-libs/gobject-introspection-0.10.3:= )
	json? ( >=dev-libs/jansson-2.5 )
	modemmanager? ( >=net-misc/modemmanager-0.7.991:0=
		net-misc/mobile-broadband-provider-info )
	ncurses? ( >=dev-libs/newt-0.52.15 )
	nss? ( >=dev-libs/nss-3.11:= )
	!nss? ( gnutls? (
		dev-libs/libgcrypt:0=
		>=net-libs/gnutls-2.12:= ) )
	ofono? ( net-misc/ofono )
	ovs? ( dev-libs/jansson )
	ppp? ( >=net-dialup/ppp-2.4.5:=[ipv6] )
	resolvconf? ( net-dns/openresolv )
	selinux? ( sys-libs/libselinux )
	teamd? (
		dev-libs/jansson
		>=net-misc/libteam-1.9
	)
"
RDEPEND="${COMMON_DEPEND}
	|| (
		net-misc/iputils[arping(+)]
		net-analyzer/arping
	)
	wifi? (
		!iwd? ( >=net-wireless/wpa_supplicant-0.7.3-r3[dbus] )
		iwd? ( net-wireless/iwd )
	)
"
DEPEND="${COMMON_DEPEND}
	dev-util/gdbus-codegen
	dev-util/glib-utils
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	>=sys-kernel/linux-headers-3.18
	virtual/pkgconfig
	introspection? (
		$(python_gen_any_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
		dev-lang/perl
		dev-libs/libxslt
	)
	vala? ( $(vala_depend) )
	test? (
		$(python_gen_any_dep '
			dev-python/dbus-python[${PYTHON_USEDEP}]
			dev-python/pygobject:3[${PYTHON_USEDEP}]')
	)
"

python_check_deps() {
	if use introspection; then
		has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]" || return
	fi
	if use test; then
		has_version "dev-python/dbus-python[${PYTHON_USEDEP}]" &&
		has_version "dev-python/pygobject:3[${PYTHON_USEDEP}]"
	fi
}

sysfs_deprecated_check() {
	ebegin "Checking for SYSFS_DEPRECATED support"

	if { linux_chkconfig_present SYSFS_DEPRECATED_V2; }; then
		eerror "Please disable SYSFS_DEPRECATED_V2 support in your kernel config and recompile your kernel"
		eerror "or NetworkManager will not work correctly."
		eerror "See https://bugs.gentoo.org/333639 for more info."
		die "CONFIG_SYSFS_DEPRECATED_V2 support detected!"
	fi
	eend $?
}

pkg_pretend() {
	if use kernel_linux; then
		get_version
		if linux_config_exists; then
			sysfs_deprecated_check
		else
			ewarn "Was unable to determine your kernel .config"
			ewarn "Please note that if CONFIG_SYSFS_DEPRECATED_V2 is set in your kernel .config, NetworkManager will not work correctly."
			ewarn "See https://bugs.gentoo.org/333639 for more info."
		fi

	fi
}

pkg_setup() {
	if use connection-sharing; then
		if kernel_is lt 5 1; then
			CONFIG_CHECK="~NF_NAT_IPV4 ~NF_NAT_MASQUERADE_IPV4"
		else
			CONFIG_CHECK="~NF_NAT ~NF_NAT_MASQUERADE"
		fi
		linux-info_pkg_setup
	fi
	enewgroup plugdev
	if use introspection || use test; then
		python-any-r1_pkg_setup
	fi
}

src_prepare() {
	DOC_CONTENTS="To modify system network connections without needing to enter the
		root password, add your user account to the 'plugdev' group."

	use vala && vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local myconf=(
		--disable-more-warnings
		--disable-static
		--localstatedir=/var
		--with-runstatedir=/run
		--disable-lto
		--disable-qt
		--without-netconfig
		--with-dbus-sys-dir=/etc/dbus-1/system.d
		--with-nmcli=yes
		--with-udev-dir="$(get_udevdir)"
		--with-config-plugins-default=keyfile
		--with-iptables=/sbin/iptables
		--with-ebpf=yes
		--enable-concheck
		--with-nm-cloud-setup=yes
		--with-crypto=$(usex nss nss gnutls)
		--with-session-tracking=$(usex elogind elogind $(usex consolekit consolekit no))
		# ConsoleKit has no build-time dependency, so use it as the default case.
		# There is no off switch, and we do not support upower.
		--with-suspend-resume=$(usex elogind elogind consolekit)
		$(use_with audit libaudit)
		$(use_enable bluetooth bluez5-dun)
		--without-dhcpcanon
		$(use_with dhclient)
		$(use_with dhcpcd)
		--with-config-dhcp-default=internal
		$(use_enable introspection)
		$(use_enable json json-validation)
		$(use_enable ppp)
		--without-libpsl
		$(use_with modemmanager modem-manager-1)
		$(use_with ncurses nmtui)
		$(use_with ofono)
		$(use_enable ovs)
		$(use_enable policykit polkit)
		$(use_with resolvconf)
		$(use_with selinux)
		--without-systemd-journal
		$(use_enable teamd teamdctl)
		$(use_enable test tests)
		$(use_enable vala)
		--without-valgrind
		$(use_with wifi iwd)
		$(use_with wext)
		$(use_enable wifi)
	)

	# Same hack as net-dialup/pptpd to get proper plugin dir for ppp, bug #519986
	if use ppp; then
		local PPPD_VER=`best_version net-dialup/ppp`
		PPPD_VER=${PPPD_VER#*/*-} #reduce it to ${PV}-${PR}
		PPPD_VER=${PPPD_VER%%[_-]*} # main version without beta/pre/patch/revision
		myconf+=( --with-pppd-plugin-dir=/usr/$(get_libdir)/pppd/${PPPD_VER} )
	fi

	# work-around man out-of-source brokenness, must be done before configure
	ln -s "${S}/docs" docs || die
	ln -s "${S}/man" man || die

	ECONF_SOURCE=${S} gnome3_src_configure "${myconf[@]}"
}

src_test() {
	if use test; then
		python_setup
		virtx emake check
	fi
}

src_install() {
	# Install completions at proper place, bug #465100
	gnome3_src_install completiondir="$(get_bashcompdir)"
	insinto /usr/lib/NetworkManager/conf.d #702476
	doins "${S}"/examples/nm-conf.d/31-mac-addr-change.conf
	
	einstalldocs

	newinitd "${FILESDIR}/init.d.NetworkManager-r2" NetworkManager
	newconfd "${FILESDIR}/conf.d.NetworkManager" NetworkManager

	# Need to keep the /etc/NetworkManager/dispatched.d for dispatcher scripts
	keepdir /etc/NetworkManager/dispatcher.d

	# Provide openrc net dependency only when nm is connected
	exeinto /etc/NetworkManager/dispatcher.d
	newexe "${FILESDIR}/10-openrc-status-r4" 10-openrc-status
	sed -e "s:@EPREFIX@:${EPREFIX}:g" \
		-i "${ED}/etc/NetworkManager/dispatcher.d/10-openrc-status" || die

	keepdir /etc/NetworkManager/system-connections
	chmod 0600 "${ED}"/etc/NetworkManager/system-connections/.keep* # bug #383765, upstream bug #754594

	# Allow users in plugdev group to modify system connections
	insinto /usr/share/polkit-1/rules.d/
	doins "${FILESDIR}/01-org.freedesktop.NetworkManager.settings.modify.system.rules"

	if use iwd; then
		# This goes to $nmlibdir/conf.d/ and $nmlibdir is '${prefix}'/lib/$PACKAGE, thus always lib, not get_libdir
		cat <<-EOF > "${ED%/}"/usr/lib/NetworkManager/conf.d/iwd.conf
		[device]
		wifi.backend=iwd
		EOF
	fi

	# Empty
	rmdir "${ED%/}"/var{/lib{/NetworkManager,},} || die
}

pkg_postinst() {
	gnome3_pkg_postinst

	if [[ -e "${EROOT}etc/NetworkManager/nm-system-settings.conf" ]]; then
		ewarn "The ${PN} system configuration file has moved to a new location."
		ewarn "You must migrate your settings from ${EROOT}/etc/NetworkManager/nm-system-settings.conf"
		ewarn "to ${EROOT}etc/NetworkManager/NetworkManager.conf"
		ewarn
		ewarn "After doing so, you can remove ${EROOT}etc/NetworkManager/nm-system-settings.conf"
	fi

	# NM fallbacks to plugin specified at compile time (upstream bug #738611)
	# but still show a warning to remember people to have cleaner config file
	if [[ -e "${EROOT}etc/NetworkManager/NetworkManager.conf" ]]; then
		if grep plugins "${EROOT}etc/NetworkManager/NetworkManager.conf" | grep -q ifnet; then
			ewarn
			ewarn "You seem to use 'ifnet' plugin in ${EROOT}etc/NetworkManager/NetworkManager.conf"
			ewarn "Since it won't be used, you will need to stop setting ifnet plugin there."
			ewarn
		fi
	fi

	# NM shows lots of errors making nmcli almost unusable, bug #528748 upstream bug #690457
	if grep -r "psk-flags=1" "${EROOT}"/etc/NetworkManager/; then
		ewarn "You have psk-flags=1 setting in above files, you will need to"
		ewarn "either reconfigure affected networks or, at least, set the flag"
		ewarn "value to '0'."
	fi

	if use dhclient || use dhcpcd; then
		ewarn "You have enabled USE=dhclient and/or USE=dhcpcd, but NetworkManager since"
		ewarn "version 1.20 defaults to the internal DHCP client. If the internal client"
		ewarn "works for you, and you're happy with it, the alternative USE flags can be"
		ewarn "disabled. If you want to use dhclient or dhcpcd, then you need to tweak"
		ewarn "the main.dhcp configuration option to use one of them instead of internal."
	fi
}
