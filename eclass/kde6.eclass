# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: kde6.eclass
# @MAINTAINER:
# kde@gentoo.org
# @BLURB: Support eclass for packages that follow KDE packaging conventions.
# @DESCRIPTION:
# This eclass is intended to streamline the creation of ebuilds for packages
# that follow KDE upstream packaging conventions. It's primarily intended for
# the three upstream release groups (Frameworks, Plasma, Applications) but
# is also for any package that follows similar conventions.
#
# This eclass unconditionally inherits kde6-functions.eclass and all its public
# functions and variables may be considered as part of this eclass's API.
#
# This eclass unconditionally inherits cmake-utils.eclass and all its public
# variables and helper functions (not phase functions) may be considered as part
# of this eclass's API.
#
# This eclass's phase functions are not intended to be mixed and matched, so if
# any phase functions are overridden the version here should also be called.

if [[ -z ${_KDE5_ECLASS} ]]; then
_KDE5_ECLASS=1

# @ECLASS-VARIABLE: VIRTUALX_REQUIRED
# @DESCRIPTION:
# For proper description see virtualx.eclass manpage.
# Here we redefine default value to be manual, if your package needs virtualx
# for tests you should proceed with setting VIRTUALX_REQUIRED=test.
: ${VIRTUALX_REQUIRED:=manual}

inherit cmake-utils flag-o-matic kde6-functions virtualx xdg

case ${EAPI} in
	6) inherit eapi7-ver eutils gnome2-utils ;;
esac

if [[ ${KDE_BUILD_TYPE} = live ]]; then
	inherit git-r3
fi

if [[ -v KDE_GCC_MINIMAL ]]; then
	EXPORT_FUNCTIONS pkg_pretend
fi

EXPORT_FUNCTIONS pkg_setup pkg_nofetch src_unpack src_prepare src_configure src_compile src_install pkg_preinst pkg_postinst pkg_postrm

# @ECLASS-VARIABLE: ECM_KDEINSTALLDIRS
# @DESCRIPTION:
# If set to "false", do nothing.
# For any other value, assume the package is using KDEInstallDirs macro and switch
# KDE_INSTALL_USE_QT_SYS_PATHS to ON.
: ${ECM_KDEINSTALLDIRS:=true}

# @ECLASS-VARIABLE: KDE_BLOCK_SLOT4
# @DESCRIPTION:
# This variable only has any effect when when CATEGORY = "kde-apps" and
# KDE_AUTODEPS is also set. If set to "true", add RDEPEND block on kde-apps/${PN}:4
: ${KDE_BLOCK_SLOT4:=true}

# @ECLASS-VARIABLE: KDE_DEBUG
# @DESCRIPTION:
# If set to "false", add -DNDEBUG (via cmake-utils_src_configure) and -DQT_NO_DEBUG
# to CPPFLAGS.
# Otherwise, add debug to IUSE.
: ${KDE_DEBUG:=true}

# @ECLASS-VARIABLE: KDE_DESIGNERPLUGIN
# @DESCRIPTION:
# If set to "false", do nothing.
# Otherwise, add "designer" to IUSE to toggle build of designer plugins
# and add the necessary DEPENDs.
: ${KDE_DESIGNERPLUGIN:=false}

# @ECLASS-VARIABLE: KDE_EXAMPLES
# @DESCRIPTION:
# If set to "false", unconditionally ignore a top-level examples subdirectory.
# Otherwise, add "examples" to IUSE to toggle adding that subdirectory.
: ${KDE_EXAMPLES:=false}

# @ECLASS-VARIABLE: KDE_HANDBOOK
# @DESCRIPTION:
# If set to "false", do nothing.
# Otherwise, add "+handbook" to IUSE, add the appropriate dependency, and
# generate and install KDE handbook.
# If set to "optional", config with -DCMAKE_DISABLE_FIND_PACKAGE_KF5DocTools=ON
# when USE=!handbook. In case package requires KF5KDELibs4Support, see next:
# If set to "forceoptional", remove a KF5DocTools dependency from the root
# CMakeLists.txt in addition to the above.
: ${KDE_HANDBOOK:=false}

# @ECLASS-VARIABLE: KDE_DOC_DIR
# @DESCRIPTION:
# Specifies the location of the KDE handbook if not the default.
: ${KDE_DOC_DIR:=doc}

# @ECLASS-VARIABLE: KDE_PO_DIRS
# @DESCRIPTION:
# Specifies the possible locations of KDE l10n files if not the default.
: ${KDE_PO_DIRS:="po poqm"}

# @ECLASS-VARIABLE: KDE_QTHELP
# @DESCRIPTION:
# If set to "false", do nothing.
# Otherwise, add "doc" to IUSE, add the appropriate dependency, generate
# and install Qt compressed help files with -DBUILD_QCH=ON when USE=doc.
if [[ ${CATEGORY} = kde-frameworks ]]; then
	: ${KDE_QTHELP:=true}
fi
: ${KDE_QTHELP:=false}

# @ECLASS-VARIABLE: KDE_TEST
# @DESCRIPTION:
# If set to "false", do nothing.
# For any other value, add test to IUSE and add a dependency on dev-qt/qttest:5.
# If set to "optional", configure with -DCMAKE_DISABLE_FIND_PACKAGE_Qt5Test=ON
# when USE=!test.
# If set to "forceoptional", remove a Qt5Test dependency and comment test
# subdirs from the root CMakeLists.txt in addition to the above.
# If set to "forceoptional-recursive", remove Qt5Test dependencies and make
# autotest(s), unittest(s) and test(s) subdirs from *any* CMakeLists.txt in ${S}
# and below conditional on BUILD_TESTING. This is always meant as a short-term
# fix and creates ${T}/${P}-tests-optional.patch to refine and submit upstream.
if [[ ${CATEGORY} = kde-frameworks ]]; then
	: ${KDE_TEST:=true}
fi
: ${KDE_TEST:=false}

# @ECLASS-VARIABLE: KDE_SELINUX_MODULE
# @DESCRIPTION:
# If set to "none", do nothing.
# For any other value, add selinux to IUSE, and depending on that useflag
# add a dependency on sec-policy/selinux-${KDE_SELINUX_MODULE} to (R)DEPEND.
: ${KDE_SELINUX_MODULE:=none}

# @ECLASS-VARIABLE: KDE_SUBSLOT
# @DESCRIPTION:
# If set to "false", do nothing.
# If set to "true", add a subslot to the package, where subslot is either
# defined as major.minor version for kde-*/ categories or ${PV} if other.
# For any other value, that value will be used as subslot.
: ${KDE_SUBSLOT:=false}

# @ECLASS-VARIABLE: KDE_UNRELEASED
# @INTERNAL
# @DESCRIPTION
# An array of $CATEGORY-$PV pairs of packages that are unreleased upstream.
# Any package matching this will have fetch restriction enabled, and receive
# a proper error message via pkg_nofetch.
KDE_UNRELEASED=( )

HOMEPAGE="https://kde.org/"
LICENSE="GPL-2"

SLOT=6

if [[ ${CATEGORY} = kde-frameworks ]]; then
	KDE_SUBSLOT=true
fi

case ${KDE_SUBSLOT} in
	false)  ;;
	true)
		case ${CATEGORY} in
			kde-frameworks | \
			kde-plasma | \
			kde-apps)
				SLOT+="/$(ver_cut 1-2)"
				;;
			*)
				SLOT+="/${PV}"
				;;
		esac
		;;
	*)
		SLOT+="/${KDE_SUBSLOT}"
		;;
esac

case ${KDE_DEBUG} in
	false)	;;
	*)
		IUSE+=" debug"
		;;
esac

case ${KDE_DESIGNERPLUGIN} in
	false)  ;;
	*)
		IUSE+=" designer"
		BDEPEND+=" designer? (
			$(add_frameworks_dep kdesignerplugin)
			$(add_qt_dep designer)
		)"
esac

case ${KDE_EXAMPLES} in
	false)  ;;
	*)
		IUSE+=" examples"
		;;
esac

case ${KDE_HANDBOOK} in
	false)	;;
	*)
		IUSE+=" +handbook"
		BDEPEND+=" handbook? ( $(add_frameworks_dep kdoctools) )"
		;;
esac

case ${KDE_QTHELP} in
	false)	;;
	*)
		IUSE+=" doc"
		COMMONDEPEND+=" doc? ( $(add_qt_dep qt-docs) )"
		BDEPEND+=" doc? (
			$(add_qt_dep qthelp)
			>=app-doc/doxygen-1.8.13-r1
		)"
		;;
esac

case ${KDE_TEST} in
	false)	;;
	*)
		IUSE+=" test"
		DEPEND+=" test? ( $(add_qt_dep qttest) )"
		;;
esac

case ${KDE_SELINUX_MODULE} in
	none)   ;;
	*)
		IUSE+=" selinux"
		RDEPEND+=" selinux? ( sec-policy/selinux-${KDE_SELINUX_MODULE} )"
		;;
esac

case ${EAPI} in
	6) DEPEND+=" ${BDEPEND}" ;;
esac

DEPEND+=" ${COMMONDEPEND} dev-util/desktop-file-utils"
RDEPEND+=" ${COMMONDEPEND}"
unset COMMONDEPEND

if [[ -n ${KMNAME} && ${KMNAME} != ${PN} && ${KDE_BUILD_TYPE} = release ]]; then
	S=${WORKDIR}/${KMNAME}-${PV}
fi

_kde_is_unreleased() {
	local pair
	for pair in "${KDE_UNRELEASED[@]}" ; do
		if [[ "${pair}" = "${CATEGORY}-${PV}" ]]; then
			return 0
		fi
	done

	return 1
}

# @FUNCTION: kde6_pkg_pretend
# @DESCRIPTION:
# Checks if the active compiler meets the minimum version requirements.
# phase function is only exported if KDE_GCC_MINIMAL is defined.
kde6_pkg_pretend() {
	debug-print-function ${FUNCNAME} "$@"
	_check_gcc_version
}

# @FUNCTION: kde6_pkg_setup
# @DESCRIPTION:
# Checks if the active compiler meets the minimum version requirements.
kde6_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"
	_check_gcc_version
}

# @FUNCTION: kde6_pkg_nofetch
# @DESCRIPTION:
# Intended for use in the KDE overlay. If this package matches something in
# KDE_UNRELEASED, display a giant warning that the package has not yet been
# released upstream and should not be used.
kde6_pkg_nofetch() {
	if ! _kde_is_unreleased ; then
		return
	fi

	eerror " _   _ _   _ ____  _____ _     _____    _    ____  _____ ____  "
	eerror "| | | | \ | |  _ \| ____| |   | ____|  / \  / ___|| ____|  _ \ "
	eerror "| | | |  \| | |_) |  _| | |   |  _|   / _ \ \___ \|  _| | | | |"
	eerror "| |_| | |\  |  _ <| |___| |___| |___ / ___ \ ___) | |___| |_| |"
	eerror " \___/|_| \_|_| \_\_____|_____|_____/_/   \_\____/|_____|____/ "
	eerror "                                                               "
	eerror " ____   _    ____ _  __    _    ____ _____ "
	eerror "|  _ \ / \  / ___| |/ /   / \  / ___| ____|"
	eerror "| |_) / _ \| |   | ' /   / _ \| |  _|  _|  "
	eerror "|  __/ ___ \ |___| . \  / ___ \ |_| | |___ "
	eerror "|_| /_/   \_\____|_|\_\/_/   \_\____|_____|"
	eerror
	eerror "${CATEGORY}/${P} has not been released to the public yet"
	eerror "and is only available to packagers right now."
	eerror ""
	eerror "This is not a bug. Please do not file bugs or contact upstream about this."
	eerror ""
	eerror "Please consult the upstream release schedule to see when this "
	eerror "package is scheduled to be released:"
	eerror "https://community.kde.org/Schedules"
}

# @FUNCTION: kde6_src_unpack
# @DESCRIPTION:
# Unpack the sources, automatically handling both release and live ebuilds.
kde6_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${KDE_BUILD_TYPE} = live ]]; then
		git-r3_src_unpack
	else
		default
	fi
}

# @FUNCTION: kde6_src_prepare
# @DESCRIPTION:
# Wrapper for cmake-utils_src_prepare with lots of extra logic for magic
# handling of linguas, tests, handbook etc.
kde6_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	cmake-utils_src_prepare

	# only build examples when required
	if ! { in_iuse examples && use examples; } ; then
		cmake_comment_add_subdirectory examples
	fi

	# only enable handbook when required
	if in_iuse handbook && ! use handbook ; then
		cmake_comment_add_subdirectory ${KDE_DOC_DIR}

		if [[ ${KDE_HANDBOOK} = forceoptional ]] ; then
			punt_bogus_dep KF5 DocTools
			sed -i -e "/kdoctools_install/ s/^/#DONT/" CMakeLists.txt || die
		fi
	fi

	# drop translations when nls is not wanted
	if in_iuse nls && ! use nls ; then
		local po
		for po in ${KDE_PO_DIRS}; do
			if [[ -d ${po} ]] ; then
				rm -r ${po} || die
			fi
		done
	fi

	# enable only the requested translations when required
	if [[ -v LINGUAS ]] ; then
		local po
		for po in ${KDE_PO_DIRS}; do
		if [[ -d ${po} ]] ; then
			pushd ${po} > /dev/null || die
			local lang
			for lang in *; do
				if [[ -e ${lang} ]] && ! has ${lang/.po/} ${LINGUAS} ; then
					case ${lang} in
						cmake_modules | \
						CMakeLists.txt | \
						${PN}.pot)	;;
						*) rm -r ${lang} || die	;;
					esac
					if [[ -e CMakeLists.txt ]] ; then
						cmake_comment_add_subdirectory ${lang}
						sed -e "/add_subdirectory([[:space:]]*${lang}\/.*[[:space:]]*)/d" \
							-i CMakeLists.txt || die
					fi
				fi
			done
			popd > /dev/null || die
		fi
		done
	fi

	if [[ ${KDE_BUILD_TYPE} = release && ${CATEGORY} != kde-apps ]] ; then
		if [[ ${KDE_HANDBOOK} != false && -d ${KDE_DOC_DIR} && -v LINGUAS ]] ; then
			pushd ${KDE_DOC_DIR} > /dev/null || die
			local lang
			for lang in *; do
				if ! has ${lang} ${LINGUAS} ; then
					cmake_comment_add_subdirectory ${lang}
				fi
			done
			popd > /dev/null || die
		fi
	fi

	# only build unit tests when required
	if ! { in_iuse test && use test; } ; then
		if [[ ${KDE_TEST} = forceoptional ]] ; then
			punt_bogus_dep Qt5 Test
			# if forceoptional, also cover non-kde categories
			cmake_comment_add_subdirectory autotests test tests
		elif [[ ${KDE_TEST} = forceoptional-recursive ]] ; then
			punt_bogus_dep Qt5 Test
			local f pf="${T}/${P}"-tests-optional.patch
			touch ${pf} || die "Failed to touch patch file"
			for f in $(find . -type f -name "CMakeLists.txt" -exec \
				grep -l "^\s*add_subdirectory\s*\(\s*.*\(auto|unit\)\?tests\?\s*)\s*\)" {} \;); do
				cp ${f} ${f}.old || die "Failed to prepare patch origfile"
				pushd ${f%/*} > /dev/null || die
					punt_bogus_dep Qt5 Test
					sed -i CMakeLists.txt -e \
						"/^#/! s/add_subdirectory\s*\(\s*.*\(auto|unit\)\?tests\?\s*)\s*\)/if(BUILD_TESTING)\n&\nendif()/" \
						|| die
				popd > /dev/null || die
				diff -Naur ${f}.old ${f} 1>>${pf}
				rm ${f}.old || die "Failed to clean up"
			done
			einfo "Build system was modified by KDE_TEST=forceoptional-recursive."
			einfo "Unified diff file ready for pickup in:"
			einfo "  ${pf}"
			einfo "Push it upstream to make this message go away."
		elif [[ ${CATEGORY} = kde-frameworks || ${CATEGORY} = kde-plasma || ${CATEGORY} = kde-apps ]] ; then
			cmake_comment_add_subdirectory autotests test tests
		fi
	fi

	# in frameworks, tests = manual tests so never build them
	if [[ ${CATEGORY} = kde-frameworks ]] && [[ ${PN} != extra-cmake-modules ]]; then
		cmake_comment_add_subdirectory tests
	fi
}

# @FUNCTION: kde6_src_configure
# @DESCRIPTION:
# Wrapper for cmake-utils_src_configure with extra logic for magic handling of
# handbook, tests etc.
kde6_src_configure() {
	debug-print-function ${FUNCNAME} "$@"

	# we rely on cmake-utils.eclass to append -DNDEBUG too
	if in_iuse debug && ! use debug; then
		append-cppflags -DQT_NO_DEBUG
	fi

	local cmakeargs

	if in_iuse test && ! use test ; then
		cmakeargs+=( -DBUILD_TESTING=OFF )

		if [[ ${KDE_TEST} = optional ]] ; then
			cmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_Qt5Test=ON )
		fi
	fi

	if in_iuse handbook && ! use handbook && [[ ${KDE_HANDBOOK} = optional ]] ; then
		cmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_KF5DocTools=ON )
	fi

	if in_iuse designer && ! use designer && [[ ${KDE_DESIGNERPLUGIN} != false ]] ; then
		cmakeargs+=( -DBUILD_DESIGNERPLUGIN=$(usex designer) )
	fi

	if [[ ${KDE_QTHELP} != false ]]; then
		cmakeargs+=( -DBUILD_QCH=$(usex doc) )
	fi

	if [[ ${ECM_KDEINSTALLDIRS} != false ]] ; then
		cmakeargs+=(
			# install mkspecs in the same directory as qt stuff
			-DKDE_INSTALL_USE_QT_SYS_PATHS=ON
		)
		# move handbook outside of doc dir for at least two QA warnings, bug 667138
		[[ ${EAPI} != 6 ]] && cmakeargs+=( -DKDE_INSTALL_DOCBUNDLEDIR="${EPREFIX}/usr/share/help" )
	fi

	# allow the ebuild to override what we set here
	mycmakeargs=("${cmakeargs[@]}" "${mycmakeargs[@]}")

	cmake-utils_src_configure
}

# @FUNCTION: kde6_src_compile
# @DESCRIPTION:
# Wrapper for cmake-utils_src_compile. Currently doesn't do anything extra, but
# is included as part of the API just in case it's needed in the future.
kde6_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	cmake-utils_src_compile "$@"
}

# @FUNCTION: kde6_src_install
# @DESCRIPTION:
# Wrapper for cmake-utils_src_install with extra logic to avoid compressing
# certain types of files. For example, khelpcenter is not able to read
# compressed handbooks.
kde6_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	cmake-utils_src_install

	# We don't want QCH and tags files to be compressed, because then
	# cmake can't find the tags and qthelp viewers can't find the docs
	local p=$(best_version dev-qt/qtcore:6)
	local pv=$(echo ${p/%-r[0-9]*/} | rev | cut -d - -f 1 | rev)
	if [[ ${pv} = 5.11* ]]; then
		#todo: clean up trailing slash check when EAPI <7 is removed
		if [[ -d ${ED%/}/usr/share/doc/qt-${pv} ]]; then
			docompress -x /usr/share/doc/qt-${pv}
		fi
	fi

	if [[ ${EAPI} = 6 ]]; then
		# We don't want /usr/share/doc/HTML to be compressed,
		# because then khelpcenter can't find the docs
		#todo: clean up trailing slash check when EAPI <7 is removed
		if [[ -d ${ED%/}/usr/share/doc/HTML ]]; then
			docompress -x /usr/share/doc/HTML
		fi
	fi
}

# @FUNCTION: kde6_pkg_preinst
# @DESCRIPTION:
# Sets up environment variables required in kde6_pkg_postinst.
kde6_pkg_preinst() {
	debug-print-function ${FUNCNAME} "$@"

	xdg_pkg_preinst
}

# @FUNCTION: kde6_pkg_postinst
# @DESCRIPTION:
# Updates the various XDG caches (icon, desktop, mime) if necessary.
kde6_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	xdg_pkg_postinst

	if [[ -z ${I_KNOW_WHAT_I_AM_DOING} ]]; then
		if [[ ${KDE_BUILD_TYPE} = live ]]; then
			echo
			einfo "WARNING! This is an experimental live ebuild of ${CATEGORY}/${PN}"
			einfo "Use it at your own risk."
			einfo "Do _NOT_ file bugs at bugs.gentoo.org because of this ebuild!"
		fi
	fi
}

# @FUNCTION: kde6_pkg_postrm
# @DESCRIPTION:
# Updates the various XDG caches (icon, desktop, mime) if necessary.
kde6_pkg_postrm() {
	debug-print-function ${FUNCNAME} "$@"

	xdg_pkg_postrm
}

fi
