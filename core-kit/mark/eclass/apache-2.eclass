# Distributed under the terms of the GNU General Public License v2

# @ECLASS: apache-2.eclass
# @MAINTAINER:
# polynomial-c@gentoo.org
# @SUPPORTED_EAPIS: 5 6 7
# @BLURB: Provides a common set of functions for apache-2.x ebuilds
# @DESCRIPTION:
# This eclass handles apache-2.x ebuild functions such as LoadModule generation
# and inter-module dependency checking.

inherit autotools flag-o-matic multilib ssl-cert user toolchain-funcs

[[ ${CATEGORY}/${PN} != www-servers/apache ]] \
	&& die "Do not use this eclass with anything else than www-servers/apache ebuilds!"

case ${EAPI:-0} in
	0|1|2|3|4)
		die "This eclass is banned for EAPI<5"
	;;
esac

# settings which are version specific go in here:
case $(ver_cut 1-2) in
	2.4)
		DEFAULT_MPM_THREADED="event" #509922
		CDEPEND=">=dev-libs/apr-1.5.1:=
			!www-apache/mod_macro" #492578 #477702
	;;
	2.2)
		DEFAULT_MPM_THREADED="worker"
		CDEPEND=">=dev-libs/apr-1.4.5:=" #368651
	;;
	*)
		die "Unknown MAJOR.MINOR apache version."
	;;
esac

# @VARIABLE: APACHE_LAYOUT
# @DESCRIPTION:
# This variable set the name of the config layout to use.
APACHE_LAYOUT=${APACHE_LAYOUT:-Funtoo}

# ==============================================================================
# INTERNAL VARIABLES
# ==============================================================================

SRC_URI="mirror://apache/httpd/httpd-${PV}.tar.bz2"

# @VARIABLE: IUSE_MPMS_FORK
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a list of forking
# (i.e.  non-threaded) MPMs

# @VARIABLE: IUSE_MPMS_THREAD
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a list of threaded
# MPMs

# @VARIABLE: IUSE_MODULES
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a list of available
# built-in modules

IUSE_MPMS="${IUSE_MPMS_FORK} ${IUSE_MPMS_THREAD}"
IUSE="${IUSE} debug doc gdbm ldap libressl selinux ssl static suexec threads"

for module in ${IUSE_MODULES} ; do
	IUSE="${IUSE} apache2_modules_${module}"
done

_apache2_set_mpms() {
	local mpm
	local ompm

	for mpm in ${IUSE_MPMS} ; do
		IUSE="${IUSE} apache2_mpms_${mpm}"

		REQUIRED_USE+=" apache2_mpms_${mpm}? ("
		for ompm in ${IUSE_MPMS} ; do
			if [[ "${mpm}" != "${ompm}" ]] ; then
				REQUIRED_USE+=" !apache2_mpms_${ompm}"
			fi
		done

		if has ${mpm} ${IUSE_MPMS_FORK} ; then
			REQUIRED_USE+=" !threads"
		else
			REQUIRED_USE+=" threads"
		fi
		REQUIRED_USE+=" )"
	done

	if [[ "$(ver_cut 1-2)" != 2.2 ]] ; then
		REQUIRED_USE+=" apache2_mpms_prefork? ( !apache2_modules_http2 )"
	fi
}
_apache2_set_mpms
unset -f _apache2_set_mpms

DEPEND="${CDEPEND}
	dev-lang/perl
	=dev-libs/apr-util-1*:=[gdbm=,ldap?]
	dev-libs/libpcre
	apache2_modules_deflate? ( sys-libs/zlib )
	apache2_modules_mime? ( app-misc/mime-types )
	gdbm? ( sys-libs/gdbm:= )
	ldap? ( =net-nds/openldap-2* )
	ssl? (
		!libressl? ( >=dev-libs/openssl-1.0.2:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	!=www-servers/apache-1*"
RDEPEND+=" ${DEPEND}
	selinux? ( sec-policy/selinux-apache )"
PDEPEND="~app-admin/apache-tools-${PV}"

S="${WORKDIR}/httpd-${PV}"

# @VARIABLE: MODULE_DEPENDS
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a space-separated
# list of dependency tokens each with a module and the module it depends on
# separated by a colon

# now extend REQUIRED_USE to reflect the module dependencies to portage
_apache2_set_module_depends() {
	local dep

	for dep in ${MODULE_DEPENDS} ; do
		REQUIRED_USE+=" apache2_modules_${dep%:*}? ( apache2_modules_${dep#*:} )"
	done
}
_apache2_set_module_depends
unset -f _apache2_set_module_depends

# ==============================================================================
# INTERNAL FUNCTIONS
# ==============================================================================

# @ECLASS-VARIABLE: MY_MPM
# @DESCRIPTION:
# This internal variable contains the selected MPM after a call to setup_mpm()

# @FUNCTION: setup_mpm
# @DESCRIPTION:
# This internal function makes sure that only one of APACHE2_MPMS was selected
# or a default based on USE=threads is selected if APACHE2_MPMS is empty
setup_mpm() {
	MY_MPM=""
	for x in ${IUSE_MPMS} ; do
		if use apache2_mpms_${x} ; then
			# there can at most be one MPM selected because of REQUIRED_USE constraints
			MY_MPM=${x}
			elog
			elog "Selected MPM: ${MY_MPM}"
			elog
			break
		fi
	done

	if [[ -z "${MY_MPM}" ]] ; then
		if use threads ; then
			MY_MPM=${DEFAULT_MPM_THREADED}
			elog
			elog "Selected default threaded MPM: ${MY_MPM}"
			elog
		else
			MY_MPM=prefork
			elog
			elog "Selected default MPM: ${MY_MPM}"
			elog
		fi
	fi
}

# @VARIABLE: MODULE_CRITICAL
# @DESCRIPTION:
# This variable needs to be set in the ebuild and contains a space-separated
# list of modules critical for the default apache. A user may still
# disable these modules for custom minimal installation at their own risk.

# @FUNCTION: check_module_critical
# @DESCRIPTION:
# This internal function warns the user about modules critical for the default
# apache configuration.
check_module_critical() {
	local unsupported=0

	for m in ${MODULE_CRITICAL} ; do
		if ! has ${m} ${MY_MODS[@]} ; then
			ewarn "Module '${m}' is required in the default apache configuration."
			unsupported=1
		fi
	done

	if [[ ${unsupported} -ne 0 ]] ; then
		ewarn
		ewarn "You have disabled one or more required modules"
		ewarn "for the default apache configuration."
		ewarn "Although this is not an error, please be"
		ewarn "aware that this setup is UNSUPPORTED."
		ewarn
	fi
}

# @ECLASS-VARIABLE: MY_CONF
# @DESCRIPTION:
# This internal variable contains the econf options for the current module
# selection after a call to setup_modules()

# @ECLASS-VARIABLE: MY_MODS
# @DESCRIPTION:
# This internal variable contains a sorted, space separated list of currently
# selected modules after a call to setup_modules()

# @FUNCTION: setup_modules
# @DESCRIPTION:
# This internal function selects all built-in modules based on USE flags and
# APACHE2_MODULES USE_EXPAND flags
setup_modules() {
	local mod_type=

	if use static ; then
		mod_type="static"
	else
		mod_type="shared"
	fi

	MY_CONF=( --enable-so=static )
	MY_MODS=()

	if use ldap ; then
		MY_CONF+=( --enable-authnz_ldap=${mod_type} --enable-ldap=${mod_type} )
		MY_MODS+=( ldap authnz_ldap )
	else
		MY_CONF+=( --disable-authnz_ldap --disable-ldap )
	fi

	if use ssl ; then
		MY_CONF+=( --with-ssl --enable-ssl=${mod_type} )
		MY_MODS+=( ssl )
	else
		MY_CONF+=( --without-ssl --disable-ssl )
	fi

	if use suexec ; then
		elog "You can manipulate several configure options of suexec"
		elog "through the following environment variables:"
		elog
		elog " SUEXEC_SAFEPATH: Default PATH for suexec (default: '${EPREFIX}/usr/local/bin:${EPREFIX}/usr/bin:${EPREFIX}/bin')"
		if { ver_test ${PV} -ge 2.4.34 && ! use suexec-syslog ; } || ver_test ${PV} -lt 2.4.34 ; then
			elog "  SUEXEC_LOGFILE: Path to the suexec logfile (default: '${EPREFIX}/var/log/apache2/suexec_log')"
		fi
		elog "   SUEXEC_CALLER: Name of the user Apache is running as (default: apache)"
		elog "  SUEXEC_DOCROOT: Directory in which suexec will run scripts (default: '${EPREFIX}/var/www')"
		elog "   SUEXEC_MINUID: Minimum UID, which is allowed to run scripts via suexec (default: 1000)"
		elog "   SUEXEC_MINGID: Minimum GID, which is allowed to run scripts via suexec (default: 100)"
		elog "  SUEXEC_USERDIR: User subdirectories (like /home/user/html) (default: public_html)"
		elog "    SUEXEC_UMASK: Umask for the suexec process (default: 077)"
		elog

		MY_CONF+=( --with-suexec-safepath="${SUEXEC_SAFEPATH:-${EPREFIX}/usr/local/bin:${EPREFIX}/usr/bin:${EPREFIX}/bin}" )
		if ver_test ${PV} -ge 2.4.34 ; then
			MY_CONF+=( $(use_with !suexec-syslog suexec-logfile "${SUEXEC_LOGFILE:-${EPREFIX}/var/log/apache2/suexec_log}") )
			MY_CONF+=( $(use_with suexec-syslog) )
			if use suexec-syslog && use suexec-caps ; then
				MY_CONF+=( --enable-suexec-capabilities )
			fi
		else
			MY_CONF+=( --with-suexec-logfile="${SUEXEC_LOGFILE:-${EPREFIX}/var/log/apache2/suexec_log}" )
		fi
		MY_CONF+=( --with-suexec-bin="${EPREFIX}/usr/sbin/suexec" )
		MY_CONF+=( --with-suexec-userdir=${SUEXEC_USERDIR:-public_html} )
		MY_CONF+=( --with-suexec-caller=${SUEXEC_CALLER:-apache} )
		MY_CONF+=( --with-suexec-docroot="${SUEXEC_DOCROOT:-${EPREFIX}/var/www}" )
		MY_CONF+=( --with-suexec-uidmin=${SUEXEC_MINUID:-1000} )
		MY_CONF+=( --with-suexec-gidmin=${SUEXEC_MINGID:-100} )
		MY_CONF+=( --with-suexec-umask=${SUEXEC_UMASK:-077} )
		MY_CONF+=( --enable-suexec=${mod_type} )
		MY_MODS+=( suexec )
	else
		MY_CONF+=( --disable-suexec )
	fi

	for x in ${IUSE_MODULES} ; do
		if use apache2_modules_${x} ; then
			MY_CONF+=( --enable-${x}=${mod_type} )
			MY_MODS+=( ${x} )
		else
			MY_CONF+=( --disable-${x} )
		fi
	done

	# sort and uniquify MY_MODS
	MY_MODS=( $(echo ${MY_MODS[@]} | tr ' ' '\n' | sort -u) )
	check_module_critical
}

# @FUNCTION: check_upgrade
# @DESCRIPTION:
# This internal function checks if the previous configuration file for built-in
# modules exists in ROOT and prevents upgrade in this case. Users are supposed
# to convert this file to the new APACHE2_MODULES USE_EXPAND variable and remove
# it afterwards.
check_upgrade() {
	if [[ -e "${EROOT}"etc/apache2/apache2-builtin-mods ]]; then
		eerror "The previous configuration file for built-in modules"
		eerror "(${EROOT}etc/apache2/apache2-builtin-mods) exists on your"
		eerror "system."
		eerror
		eerror "Please read https://wiki.gentoo.org/wiki/Project:Apache/Upgrading"
		eerror "for detailed information how to convert this file to the new"
		eerror "APACHE2_MODULES USE_EXPAND variable."
		eerror
		die "upgrade not possible with existing ${ROOT}etc/apache2/apache2-builtin-mods"
	fi
}

# ==============================================================================
# EXPORTED FUNCTIONS
# ==============================================================================

# @FUNCTION: apache-2_pkg_setup
# @DESCRIPTION:
# This function selects built-in modules, the MPM and other configure options,
# creates the apache user and group and informs about CONFIG_SYSVIPC being
# needed (we don't depend on kernel sources and therefore cannot check).
apache-2_pkg_setup() {
	check_upgrade

	# setup apache user and group
	enewgroup apache 81
	enewuser apache 81 -1 /var/www apache

	setup_mpm
	setup_modules

	if use debug; then
		MY_CONF+=( --enable-exception-hook )
	fi

	elog "Please note that you need SysV IPC support in your kernel."
	elog "Make sure CONFIG_SYSVIPC=y is set."
	elog

	if use userland_BSD; then
		elog "On BSD systems you need to add the following line to /boot/loader.conf:"
		elog "  accf_http_load=\"YES\""
		if use ssl ; then
			elog "  accf_data_load=\"YES\""
		fi
		elog
	fi
}

# @FUNCTION: apache-2_src_configure
# @DESCRIPTION:
# This function adds compiler flags and runs econf and emake based on MY_MPM and
# MY_CONF
apache-2_src_configure() {
	tc-export PKG_CONFIG

	# Sanity check in case people have bad mounts/TPE settings. #500928
	if ! "${T}"/pcre-config --help >/dev/null ; then
		eerror "Could not execute ${T}/pcre-config; do you have bad mount"
		eerror "permissions in ${T} or have TPE turned on in your kernel?"
		die "check your runtime settings #500928"
	fi

	# Instead of filtering --as-needed (bug #128505), append --no-as-needed
	# Thanks to Harald van Dijk
	append-ldflags $(no-as-needed)

	# Brain dead check.
	tc-is-cross-compiler && export ap_cv_void_ptr_lt_long="no"

	# peruser MPM debugging with -X is nearly impossible
	if has peruser ${IUSE_MPMS} && use apache2_mpms_peruser ; then
		use debug && append-flags -DMPM_PERUSER_DEBUG
	fi

	# econf overwrites the stuff from config.layout, so we have to put them into
	# our myconf line too
	MY_CONF+=(
		--includedir="${EPREFIX}"/usr/include/apache2
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/apache2/modules
		--datadir="${EPREFIX}"/var/www/localhost
		--sysconfdir="${EPREFIX}"/etc/apache2
		--localstatedir="${EPREFIX}"/var
		--with-mpm=${MY_MPM}
		--with-apr="${SYSROOT}${EPREFIX}"/usr
		--with-apr-util="${SYSROOT}${EPREFIX}"/usr
		--with-pcre="${T}"/pcre-config
		--with-z="${EPREFIX}"/usr
		--with-port=80
		--with-program-name=apache2
		--enable-layout=${APACHE_LAYOUT}
	)
	ac_cv_path_PKGCONFIG=${PKG_CONFIG} \
	econf "${MY_CONF[@]}"

	sed -i -e 's:apache2\.conf:httpd.conf:' include/ap_config_auto.h || die
}

# @FUNCTION: apache-2_pkg_postinst
# @DESCRIPTION:
# This function creates test certificates if SSL is enabled and installs the
# default index.html to /var/www/localhost if it does not exist. We do this here
# because the default webroot is a copy of the files that exist elsewhere and we
# don't want them to be managed/removed by portage when apache is upgraded.
apache-2_pkg_postinst() {
	if use ssl && [[ ! -e "${EROOT}/etc/ssl/apache2/server.pem" ]]; then
		SSL_ORGANIZATION="${SSL_ORGANIZATION:-Apache HTTP Server}"
		install_cert /etc/ssl/apache2/server
		ewarn
		ewarn "The location of SSL certificates has changed. If you are"
		ewarn "upgrading from ${CATEGORY}/${PN}-2.2.13 or earlier (or remerged"
		ewarn "*any* apache version), you might want to move your old"
		ewarn "certificates from /etc/apache2/ssl/ to /etc/ssl/apache2/ and"
		ewarn "update your config files."
		ewarn
	fi

	if [[ ! -e "${EROOT}/var/www/localhost" ]] ; then
		mkdir -p "${EROOT}/var/www/localhost/htdocs"
		echo "<html><body><h1>It works!</h1></body></html>" > "${EROOT}/var/www/localhost/htdocs/index.html"
	fi

	echo
	elog "Attention: cgi and cgid modules are now handled via APACHE2_MODULES flags"
	elog "in make.conf. Make sure to enable those in order to compile them."
	elog "In general, you should use 'cgid' with threaded MPMs and 'cgi' otherwise."
	echo

}

EXPORT_FUNCTIONS pkg_setup src_configure pkg_postinst
