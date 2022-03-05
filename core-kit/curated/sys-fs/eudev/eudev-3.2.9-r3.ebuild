# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KV_min=2.6.39

inherit autotools linux-info toolchain-funcs user

SRC_URI="https://dev.gentoo.org/~blueness/${PN}/${P}.tar.gz"
KEYWORDS="*"

DESCRIPTION="Linux dynamic and persistent device naming support (aka userspace devfs)"
HOMEPAGE="https://github.com/gentoo/eudev"

LICENSE="LGPL-2.1 MIT GPL-2"
SLOT="0"
IUSE="+hwdb +kmod introspection +rule-generator selinux static-libs test user"
RESTRICT="!test? ( test )"

COMMON_DEPEND=">=sys-apps/util-linux-2.20
	introspection? ( >=dev-libs/gobject-introspection-1.38 )
	kmod? ( >=sys-apps/kmod-16 )
	selinux? ( >=sys-libs/libselinux-2.1.9 )
	!<sys-libs/glibc-2.11
	!sys-apps/gentoo-systemd-integration
	!sys-apps/systemd"
DEPEND="${COMMON_DEPEND}
	dev-util/gperf
	virtual/os-headers
	virtual/pkgconfig
	>=sys-devel/make-3.82-r4
	>=sys-kernel/linux-headers-${KV_min}
	>=dev-util/intltool-0.50
	test? ( app-text/tree dev-lang/perl )"

RDEPEND="${COMMON_DEPEND}
	!<sys-fs/lvm2-2.02.103
	!<sec-policy/selinux-base-2.20120725-r10
	!sys-fs/udev
	!sys-apps/systemd
	!sys-fs/udev-init-scripts"

PDEPEND="hwdb? ( >=sys-apps/hwids-20140304[udev] )"

pkg_setup() {
	CONFIG_CHECK="~BLK_DEV_BSG ~DEVTMPFS ~!IDE ~INOTIFY_USER ~!SYSFS_DEPRECATED ~!SYSFS_DEPRECATED_V2 ~SIGNALFD ~EPOLL ~FHANDLE ~NET ~UNIX"
	linux-info_pkg_setup
	get_running_version

	# These are required kernel options, but we don't error out on them
	# because you can build under one kernel and run under another.
	if kernel_is lt ${KV_min//./ }; then
		ewarn
		ewarn "Your current running kernel version ${KV_FULL} is too old to run ${P}."
		ewarn "Make sure to run udev under kernel version ${KV_min} or above."
		ewarn
	fi
}

src_prepare() {
	# change rules back to group uucp instead of dialout for now
	sed -e 's/GROUP="dialout"/GROUP="uucp"/' -i rules/*.rules \
	|| die "failed to change group dialout to uucp"

	# FL-9484: enable net-generator for VMware virtual interfaces:
	sed -i -e '/^# ignore VMWare/,+1d' rule_generator/75-persistent-net-generator.rules || die "fail"

	eapply_user
	eautoreconf
}

src_configure() {
	tc-export CC #463846
	export cc_cv_CFLAGS__flto=no #502950

	# Keep sorted by ./configure --help and only pass --disable flags
	# when *required* to avoid external deps or unnecessary compile
	local econf_args
	econf_args=(
		ac_cv_search_cap_init=
		ac_cv_header_sys_capability_h=yes
		DBUS_CFLAGS=' '
		DBUS_LIBS=' '
		--with-rootprefix=
		--with-rootrundir=/run
		--exec-prefix="${EPREFIX}"
		--bindir="${EPREFIX}"/bin
		--includedir="${EPREFIX}"/usr/include
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		--with-rootlibexecdir="${EPREFIX}"/lib/udev
		--enable-split-usr
		--enable-manpages
		--disable-hwdb
		--with-rootlibdir="${EPREFIX}"/$(get_libdir)
		$(use_enable introspection)
		$(use_enable kmod)
		$(use_enable static-libs static)
		$(use_enable selinux)
		$(use_enable rule-generator)
		)
	ECONF_SOURCE="${S}" econf "${econf_args[@]}"
}

src_test() {
	# make sandbox get out of the way
	# these are safe because there is a fake root filesystem put in place,
	# but sandbox seems to evaluate the paths of the test i/o instead of the
	# paths of the actual i/o that results.
	# also only test for native abi
	addread /sys
	addwrite /dev
	addwrite /run
	default_src_test
}

src_install() {
	find "${D}" -name '*.la' -delete || die
	insinto /lib/udev/rules.d
	for x in udev udev-trigger udev-settle; do
		doinitd "${FILESDIR}"/$x
	done
	doins "${FILESDIR}"/40-gentoo.rules
	use rule-generator && doinitd "${FILESDIR}"/udev-postmount
	default
}

add_initd_to_runlevel() {
	if [[ ! -x "${EROOT}"/etc/init.d/${1} ]]; then
		die "${EROOT}/etc/init.d/${1} not found."
	fi
	if [[ ! -d "${EROOT}"/etc/runlevels/${2} ]]; then
		die "Runlevel ${2} not found."
	fi
	if [[ ! -L "${EROOT}/etc/runlevels/${2}/${1}" ]]; then
		ln -snf /etc/init.d/${1} "${EROOT}"/etc/runlevels/${2}/${1} || die "Couldn't add ${1} to runlevel ${2}"
		ewarn "Adding ${1} to the ${2} runlevel"
	fi
}

pkg_postinst() {
	enewgroup input
	enewgroup kvm 78
	enewgroup render
	mkdir -p "${EROOT}"run
	# "losetup -f" is confused if there is an empty /dev/loop/, Bug #338766
	# So try to remove it here (will only work if empty).
	rmdir "${EROOT}"dev/loop 2>/dev/null
	if [[ -d ${EROOT}dev/loop ]]; then
		ewarn "Please make sure your remove /dev/loop,"
		ewarn "else losetup may be confused when looking for unused devices."
	fi

	# REPLACING_VERSIONS should only ever have zero or 1 values but in case it doesn't,
	# process it as a list.  We only care about the zero case (new install) or the case where
	# the same version is being re-emerged.  If there is a second version, allow it to abort.
	local rv rvres=doitnew
	for rv in ${REPLACING_VERSIONS} ; do
		if [[ ${rvres} == doit* ]]; then
			if [[ ${rv%-r*} == ${PV} ]]; then
				rvres=doit
			else
				rvres=${rv}
			fi
		fi
	done

	if use hwdb && has_version 'sys-apps/hwids[udev]'; then
		udevadm hwdb --update --root="${ROOT%/}"

		# https://cgit.freedesktop.org/systemd/systemd/commit/?id=1fab57c209035f7e66198343074e9cee06718bda
		# reload database after it has be rebuilt, but only if we are not upgrading
		if [[ ${rvres} == doit* ]] && [[ ${ROOT%/} == "" ]]; then
			udevadm control --reload
		fi
	fi
	if [[ ${rvres} != doitnew ]]; then
		ewarn
		ewarn "You need to restart eudev as soon as possible to make the"
		ewarn "upgrade go into effect:"
		ewarn "\t/etc/init.d/udev --nodeps restart"
	fi

	for f in udev udev-trigger; do
		add_initd_to_runlevel $f sysinit
	done

	if use rule-generator; then
		add_initd_to_runlevel udev-postmount default
	fi
}
