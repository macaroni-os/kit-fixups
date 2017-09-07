# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 python3_4 python3_5 python3_6 )

PYTHON_REQ_USE='bzip2(+),threads(+)'

inherit distutils-r1

DESCRIPTION="Portage is the package management and distribution system for Gentoo"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Portage"

LICENSE="GPL-2"
KEYWORDS=""
SLOT="0"
IUSE="build doc +fast +ipc linguas_ru selinux xattr"

DEPEND="
	>=app-arch/tar-1.27
	>=sys-apps/sed-4.0.5 sys-devel/patch
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )"
# Require sandbox-2.2 for bug #288863.
# For xattr, we can spawn getfattr and setfattr from sys-apps/attr, but that's
# quite slow, so it's not considered in the dependencies as an alternative to
# to python-3.3 / pyxattr. Also, xattr support is only tested with Linux, so
# for now, don't pull in xattr deps for other kernels.
# For whirlpool hash, require python[ssl] (bug #425046).
# For compgen, require bash[readline] (bug #445576).
RDEPEND="
	>=app-arch/tar-1.27
	!build? (
		>=sys-apps/sed-4.0.5
		app-shells/bash:0[readline]
		>=app-admin/eselect-1.2
	)
	elibc_FreeBSD? ( sys-freebsd/freebsd-bin )
	elibc_glibc? ( >=sys-apps/sandbox-2.2 )
	elibc_musl? ( >=sys-apps/sandbox-2.2 )
	elibc_uclibc? ( >=sys-apps/sandbox-2.2 )
	>=app-misc/pax-utils-0.1.17
	selinux? ( >=sys-libs/libselinux-2.0.94[python] )
	xattr? ( >=sys-apps/install-xattr-0.3 )
	!<app-admin/logrotate-3.8.0"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
	)
	>=app-admin/ego-2.0.7"

SRC_ARCHIVES="https://dev.gentoo.org/~zmedico/portage/archives"

prefix_src_archives() {
	local x y
	for x in ${@}; do
		for y in ${SRC_ARCHIVES}; do
			echo ${y}/${x}
		done
	done
}

TARBALL_PV=${PV}
SRC_URI="mirror://gentoo/${PN}-${TARBALL_PV}.tar.bz2
	$(prefix_src_archives ${PN}-${TARBALL_PV}.tar.bz2)"

pkg_setup() {
	if use fast; then
	PATCHES+=( 
		"${FILESDIR}/${PN}-2.3.8-fast-1.3.patch"
	)
	fi
}

PATCHES=(
	"${FILESDIR}/${PN}-2.4.3-remove-gentoo-repos-conf.patch"
	"${FILESDIR}/${PN}-2.3.8-change-global-paths.patch"
	"${FILESDIR}/${PN}-2.3.8-backtrack-is-incredibly-slow.patch"
)

src_prepare() {
	for p in ${PATCHES[@]}; do
		epatch $p || die
	done
	if ! use ipc ; then
		einfo "Disabling ipc..."
		sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
			-i pym/_emerge/AbstractEbuildProcess.py || \
			die "failed to patch AbstractEbuildProcess.py"
	fi

	if use xattr && use kernel_linux ; then
		einfo "Adding FEATURES=xattr to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} xattr"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	cd $S/bin
	#s:^\(\s+\).*$:\1sys.path.insert(0, "/usr/share/portage/pym" ):
	for x in $(find . -type f); do
		einfo "Tweaking $x..."
		sed -i \
			-e '/^[[:space:]]*import portage[[:space:]]*$/ {
	h
	s:import portage:sys.path.insert(0, "/usr/share/portage/pym" ):p
	x
}' \
			-e 's:/usr/bin/python:/usr/bin/python3:g' \
		$x
	done
	cd $S/pym/portage
	sed -i -e "s/^VERSION = \"HEAD\".*$/VERSION = \"$PV-funtoo\"/" __init__.py || die
	sed -i \
		-e 's:^PORTAGE_BASE_PATH.*$:PORTAGE_BASE_PATH = "/usr/share/portage":' \
		-e 's:^PORTAGE_PYM_PATH.*$:PORTAGE_PYM_PATH = PORTAGE_BASE_PATH + "/pym":' \
	const.py || die
	
}

src_install() {
	dodir /usr/share/portage
	cp -a $S/pym $D/usr/share/portage
	cp -a $S/bin $D/usr/share/portage
	insinto /usr/share/portage/config
	doins cnf/make.globals
	insinto /usr/share/portage/config/sets
	doins cnf/sets/portage.conf
	doman man/*[1-9]
	for x in dispatch-conf env-update etc-update; do
		dosym /usr/share/portage/bin/$x /usr/sbin/$x
	done
	for x in ebuild egencache emerge portageq quickpkg; do
		dosym /usr/share/portage/bin/$x /usr/bin/$x
	done
	keepdir /etc/portage
	insinto /etc/logrotate.d
	doins cnf/logrotate.d/elog-save-summary
	insinto /etc
	doins cnf/etc-update.conf cnf/dispatch-conf.conf
}

pkg_preinst() {
	keepdir /var/log/portage/elog
	# This is allowed to fail if the user/group are invalid for prefix users.
	if chown portage:portage "${ED}"var/log/portage{,/elog} 2>/dev/null ; then
		chmod g+s,ug+rwx "${ED}"var/log/portage{,/elog}
	fi
}

pkg_postinst() {
	ewarn "Don't worry! --"
	ewarn "Funtoo's downgrade to Portage-2.3.8 is intentional. We are syncing with upstream versions."
	echo
	if [ ! -d $ROOT/var/cache/portage ]; then
		echo
		ewarn "SOMEWHAT IMPORTANT:"
		echo
		ewarn "Default distfiles and packages directories are now in /var/cache/portage. Please adjust"
		ewarn "your system as needed!"
		install -d -g portage -o portage /var/cache/portage/distfiles
	fi
}
