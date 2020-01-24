inherit eutils

case "${EAPI}" in
	5|6) inherit eapi7-ver ;;
esac

## Helper functions

# Run a function if it is defined
_run_function_if_exists() {
	[ "$(type -t ${1})" = "function" ] && ${1}
}

# toolchain_gcc_version_setup <gcc-pv[r]>
toolchain_gcc_version_setup() {
	# If we've been passed an argument, treat it as our TOOLCHAIN_GCC_PVR
	[ -n "${1}" ] && TOOLCHAIN_GCC_PVR="${1}"
	# If only T.C._GCC_PVR is set, not T.C._GCC_PV, parse T.C._GCC_PVR into T.C_GCC_P[VR]
	if [ -z "${TOOLCHAIN_GCC_PV}" ] && [ -n "${TOOLCHAIN_GCC_PVR}" ] ; then
		TOOLCHAIN_GCC_PV="${TOOLCHAIN_GCC_PVR%-r*}"
		TOOLCHAIN_GCC_PR="${TOOLCHAIN_GCC_PVR##*-r}"
		if [ "${TOOLCHAIN_GCC_PV}" -eq "${TOOLCHAIN_GCC_PR}" ] ; then
			TOOLCHAIN_GCC_PR=""
		else
			TOOLCHAIN_GCC_PR="r${TOOLCHAIN_GCC_PR}"
		fi
	fi

	# Set our GCC_P{V,R,VR} variables using the TOOLCHAIN_GCC_{V,R,PVR} if given, falling back to the package version
	GCC_PV="${TOOLCHAIN_GCC_PV:=${PV}}"
	GCC_PR="${TOOLCHAIN_GCC_PR=${PR%r0}}"
	GCC_PVR="${TOOLCHAIN_GCC_PVR:=${GCC_PV}${GCC_PR:+-${GCC_PR}}}"

	# Split GCC_PV into GCC{MAJOR,MINOR,MICRO}
	GCCMAJOR="$(ver_cut 1 ${GCC_PV})"
	GCCMINOR="$(ver_cut 2 ${GCC_PV})"
	GCCMICRO="$(ver_cut 3 ${GCC_PV})"

	# Define our GCC branch version ( just GCCMAJOR since 5.0 )
	GCC_BRANCH_VER="${GCCMAJOR}"
	# Define our GCC release version as the major.minor.micro
	GCC_RELEASE_VER="${GCCMAJOR}.${GCCMINOR}.${GCCMICRO}"

	case "${GCC_PV}" in
		*_pre*) GCC_RELEASE_TYPE="pre"; GCC_ARCHIVE_VER="${GCC_PV%_pre*}-${GCC_PV##*_pre}" ; GCC_VER_EXT="${GCC_PV##*_pre}" ;;
		*_p*) GCC_RELEASE_TYPE="patch"; GCC_VER_EXT="${GCC_PV##*_p}" ;;
		*_alpha*) GCC_RELEASE_TYPE="alpha" ; GCC_VER_EXT="${GCC_PV##*_alpha}" ;;
		*_beta*) GCC_RELEASE_TYPE="beta" ; GCC_VER_EXT="${GCC_PV##*_beta}" ;;
		*_rc*) GCC_RELEASE_TYPE="rc" ; GCC_ARCHIVE_VER="${GCC_PV%_rc*}-RC-${GCC_PV##*_rc}" ; GCC_VER_EXT="${GCC_PV##*_rc}" ;;
		*) GCC_RELEASE_TYPE="release" ; GCC_ARCHIVE_VER="${GCC_RELEASE_VER}" ;;
	esac

	case "${GCC_RELEASE_TYPE}" in
		patch|alpha|beta)
			case "${GCC_VER_EXT}" in
				# Handle dates in YYYYMMDD form.
				#Y   Y    Y    Y   M    M     D    D
				2[0-9][0-9][0-9][01][0-9][0123][0-9])
					GCC_ARCHIVE_VER="${GCC_BRANCH_VER}-${GCC_VER_EXT}"
					GCC_SNAPSHOT_DATE="${GCC_VER_EXT}"
				;;
				# Otherwise, assume SVN rev.
				*)
					GCC_ARCHIVE_VER="${GCC_RELEASE_VER%.*}.0}"
					GCC_SVN_REV="${GCC_VER_EXT}"
					GCC_SVN_PATCH_NAME="gcc-${GCC_ARCHIVE_VER}-to-svn-${GCC_SVN_REV}.patch"
				;;
			esac
		;;
	esac

	# Define our GCC configuration version, including the extra info as appropriate
	GCC_CONFIG_VER="${GCC_RELEASE_VER}${GCC_VER_EXT:+-${GCC_RELEASE_TYPE}${GCC_VER_EXT}${GCC_SVN_REV:+svn}${GCC_SNAPSHOT_DATE:+snapshot}}"

	export TOOLCHAIN_GCC_PVR TOOLCHAIN_GCC_PV TOOLCHAIN_GCC_PR
	export GCC_PVR GCC_PV GCC_PR
	export GCCMAJOR GCCMINOR GCCMICRO
	export GCC_BRANCH_VER GCC_RELEASE_VER GCC_CONFIG_VER
	export GCC_RELEASE_TYPE GCC_ARCHIVE_VER

	[ -n "${GCC_SNAPSHOT_DATE}" ] && export GCC_SNAPSHOT_DATE
	[ -n "${GCC_SVN_REV}" ] && export GCC_SVN_REV GCC_SVN_PATCH_NAME
}


# Call after toolchain_gcc_version_setup
toolchain_gcc_get_src_uri() {
	: "${GCC_SRC_URI_ROOT:="ftp://gcc.gnu.org/pub/gcc"}"

	## Set URI for GCC itself.

	# Releases and svn patches from releases handled if so indicated
	if [ "${GCC_RELEASE_TYPE}" = "release" ] || [ -n "${GCC_SVN_REV}" ] ; then
		GCC_SRC_URI="${GCC_SRC_URI_ROOT}/releases/gcc-${GCC_ARCHIVE_VER}/gcc-${GCC_ARCHIVE_VER}.tar.xz"
	# Otherwise, handle prereleases and snapshots
	else
		case "${GCC_RELEASE_TYPE}" in
			pre) GCC_SRC_URI="${GCC_SRC_URI_ROOT}/prerelease-${GCC_ARCHIVE_VER}/gcc-${GCC_ARCHIVE_VER}.tar.xz" ;;
			alpha|beta|rc|patch) GCC_SRC_URI="${GCC_SRC_URI_ROOT}/snapshots/${GCC_ARCHIVE_VER}/gcc-${GCC_ARCHIVE_VER}.tar.xz" ;;
		esac
	fi

	## Set URI for SVN patches.

	if [ -n "${GCC_SVN_REV}" ] ; then
		[ -n "${GCC_SVN_PATCH_URI_ROOT}" ] && GCC_SRC_URI="${GCC_SRC_URI} ${GCC_SVN_PATCH_URI_ROOT}/${GCC_SVN_PATCH_NAME}"
	fi

	## Grab prerequisites as well if building them in-tree is enabled
	if [ "${IUSE##*system-mathlibs*}" != "${IUSE}" ] ; then
		: "${GCC_PREREQ_GMP:="gmp-6.1.0"}"
		: "${GCC_PREREQ_MPFR:="mpfr-3.1.4"}"
		: "${GCC_PREREQ_MPC:="mpc-1.0.3"}"
		: "${GCC_PREREQ_ISL:="isl-0.18"}"

		GCC_SRC_URI="${GCC_SRC_URI}
			!system-mathlibs? (
				mirror://gnu/gmp/${GCC_PREREQ_GMP}.tar.xz
				https://www.mpfr.org/${GCC_PREREQ_MPFR}/${GCC_PREREQ_MPFR}.tar.xz
				https://ftp.gnu.org/gnu/mpc/${GCC_PREREQ_MPC}.tar.gz
				graphite? ( https://isl.gforge.inria.fr/${GCC_PREREQ_ISL}.tar.xz )
			)
		"

		# Export these in case they were defined with default values here.
		export GCC_PREREQ_GMP GCC_PREREQ_MPFR GCC_PREREQ_MPC GCC_PREREQ_ISL
	fi

	if [ "${IUSE##*bundle-gdb*}" != "${IUSE}" ] ; then
		: "${GCC_PREREQ_GDB:="gdb-8.2.1"}"
		GCC_SRC_URI="${GCC_SRC_URI}
			bundle-gdb? ( ftp://gcc.gnu.org/pub/gdb/releases/${GCC_PREREQ_GDB}.tar.xz )
		"
		export GCC_PREREQ_GDB
	fi

	if [ "${IUSE##*bundle-binutils*}" != "${IUSE}" ] ; then
		: "${GCC_PREREQ_BINUTILS:="binutils-2.31.1"}"
		GCC_SRC_URI="${GCC_SRC_URI}
			bundle-binutils? ( ftp://gcc.gnu.org/pub/binutils/releases/${GCC_PREREQ_BINUTILS}.tar.xz )
		"
		export GCC_PREREQ_BINUTILS
	fi

	# To add: bison, dejagnu, flex, m4, elfutils, tcl, tk, expect, guile

	if [ "${IUSE##*newlib*}" != "${IUSE}" ] ; then
		: "${GCC_PREREQ_NEWLIB:="newlib-3.1.0"}"
		GCC_SRC_URI="${GCC_SRC_URI}
			newlib? ( ftp://sourceware.org/pub/newlib/${GCC_PREREQ_NEWLIB}.tar.gz )
		"
		export GCC_PREREQ_NEWLIB
	fi

	export GCC_SRC_URI
}

# Compatibility wrapper for gentoo
get_gcc_src_uri() {
	toolchain_gcc_get_src_uri
	printf -- '%s' "${GCC_SRC_URI}"
}


# Needs rewrite to clean up and abstract
# Unpack the toolchain
toolchain_gcc_src_unpack() {
	default

	# Build the combined build tree
	mkdir -p "${WORKDIR}/gcc"
	for mydir in "${GCC_PREREQ_NEWLIB}" "${GCC_PREREQ_GDB}" "${GCC_PREREQ_BINUTILS}" "gcc-${GCC_RELEASE_VER}" ; do
		#[ -n "${mydir}" ] && [ -d "${WORKDIR}/${mydir}" ] && sh "${WORKDIR}/gcc-${GCC_RELEASE_VER}/symlink-tree" "${WORKDIR}/${mydir}"
		if [ -n "${mydir}" ] && [ -d "${WORKDIR}/${mydir}" ] ; then
			cd "${WORKDIR}/${mydir}" && find . -print | cpio -pdlmu ../gcc && cd -
		fi
	done

	# Fix outdated ansidecl.h in gcc needed for binutils
	if [ -n "${GCC_PREREQ_BINUTILS}" ] && [ -d "${WORKDIR}/${GCC_PREREQ_BINUTILS}" ] ; then
		cd "${WORKDIR}/${GCC_PREREQ_BINUTILS}" && find ./include/ansidecl.h -print | cpio -pdlm ../gcc && cd -
	fi
		


	# Link any mathlibs we unpacked into the gcc source tree with the version stripped from the dir name.
	local mathlib
	for mathlib in "${GCC_PREREQ_GMP}" "${GCC_PREREQ_MPFR}" "${GCC_PREREQ_MPC}" "${GCC_PREREQ_ISL}" ; do
		#[ -n "${mathlib}" ] && [ -d "${WORKDIR}/${mathlib}" ] && mv -v "${WORKDIR}/${mathlib}" "${WORKDIR}/gcc-${GCC_RELEASE_VER}/${mathlib%%-*}"
		[ -n "${mathlib}" ] && [ -d "${WORKDIR}/${mathlib}" ] && rm -rf "${WORKDIR}/gcc/${mathlib%%-*}" && ln -sfv "${WORKDIR}/${mathlib}" "${WORKDIR}/gcc/${mathlib%%-*}"
	done

}


##
# Build/Crossbuild environment
# CBUILD -- Builder system
# CHOST  -- Runtime system
# CTARGET -- Target system
#
# _FOR_BUILD -- Used to build artifacts (on CBUILD) to run on CHOST.
# _FOR_TARGET -- Used when building artifacts for CTARGET.
##


# Define any undefined C* variables to sane values
: "${CTARGET:=${CHOST}}"
: "${CBUILD:=${CHOST}}"

# Play nice with crossdev package semantics
if [ "${CTARGET}" = "${CHOST}" ] ; then
	case "${CATEGORY}" in cross-*) CTARGET="${CATEGORY#cross-}" ;; esac
fi

# Export our CHOST/CBUILD/CTARGET values
export CBUILD CHOST CTARGET

# True when we are building gcc on a different tuple than we will be running it.
toolchain_gcc_is_crossbuild() {
	[ "${CBUILD:-${CHOST}}" != "${CHOST}" ]
}

# True when we will be building gcc to target a different tuple than it runs on.
toolchain_gcc_is_crosscompiler() {
	[ "${CHOST}" != "${CTARGET:-${CHOST}}" ]
}

# True when cross-building a cross-compiler.
toolchain_gcc_is_canadiancross() {
	toolchain_gcc_is_crossbuild && toolchain_gcc_is_crosscompiler
}



toolchain_gcc_setup_tools() {

	if toolchain_gcc_is_crossbuild ; then
		AR_FOR_BUILD="${AR_FOR_BUILD-ar}"
		AS_FOR_BUILD="${AS_FOR_BUILD-as}"
		CC_FOR_BUILD="${CC_FOR_BUILD-gcc}"
		CXX_FOR_BUILD="${CXX_FOR_BUILD-g++}"
		GFORTRAN_FOR_BUILD="${GFORTRAN_FOR_BUILD-gfortran}"
		GOC_FOR_BUILD="${GOC_FOR_BUILD-gccgo}"
		DLLTOOL_FOR_BUILD="${DLLTOOL_FOR_BUILD-dlltool}"
		LD_FOR_BUILD="${LD_FOR_BUILD-ld}"
		NM_FOR_BUILD="${NM_FOR_BUILD-nm}"
		RANLIB_FOR_BUILD="${RANLIB_FOR_BUILD-ranlib}"
		WINDRES_FOR_BUILD="${WINDRES_FOR_BUILD-windres}"
		WINDMC_FOR_BUILD="${WINDMC_FOR_BUILD-windmc}"
	else
		AR_FOR_BUILD="${AR}"
		AS_FOR_BUILD="${AS}"
		CC_FOR_BUILD="${CC}"
		CXX_FOR_BUILD="${CXX}"
		GFORTRAN_FOR_BUILD="${GFORTRAN}"
		GOC_FOR_BUILD="${GOC}"
		DLLTOOL_FOR_BUILD="${DLLTOOL}"
		LD_FOR_BUILD="${LD}"
		NM_FOR_BUILD="${NM}"
		RANLIB_FOR_BUILD="${RANLIB}"
		WINDRES_FOR_BUILD="${WINDRES}"
		WINDMC_FOR_BUILD="${WINDMC}"
	fi

	if toolchain_gcc_is_crosscompiler ; then
		AR_FOR_TARGET="${AR_FOR_TARGET-ar}"
		AS_FOR_TARGET="${AS_FOR_TARGET-as}"
		CC_FOR_TARGET="${CC_FOR_TARGET-gcc}"
		CXX_FOR_TARGET="${CXX_FOR_TARGET-g++}"
		GFORTRAN_FOR_TARGET="${GFORTRAN_FOR_TARGET-gfortran}"
		GOC_FOR_TARGET="${GOC_FOR_TARGET-gccgo}"
		DLLTOOL_FOR_TARGET="${DLLTOOL_FOR_TARGET-dlltool}"
		LD_FOR_TARGET="${LD_FOR_TARGET-ld}"
		LIPO_FOR_TARGET="${LIPO_FOR_TARGET-lipo}"
		NM_FOR_TARGET="${NM_FOR_TARGET-nm}"
		OBJCOPY_FOR_TARGET="${OBJCOPY_FOR_TARGET-objcopy}"
		OBJDUMP_FOR_TARGET="${OBJDUMP_FOR_TARGET-objdump}"
		RANLIB_FOR_TARGET="${RANLIB_FOR_TARGET-ranlib}"
		READELF_FOR_TARGET="${READELF_FOR_TARGET-readelf}"
		STRIP_FOR_TARGET="${STRIP_FOR_TARGET-strip}"
		WINDRES_FOR_TARGET="${WINDRES_FOR_TARGET-windres}"
		WINDMC_FOR_TARGET="${WINDMC_FOR_TARGET-windmc}"
	else
		AR_FOR_TARGET="${AR}"
		AS_FOR_TARGET="${AS}"
		CC_FOR_TARGET="${CC}"
		CXX_FOR_TARGET="${CXX}"
		GFORTRAN_FOR_TARGET="${GFORTRAN}"
		GOC_FOR_TARGET="${GOC}"
		DLLTOOL_FOR_TARGET="${DLLTOOL}"
		LD_FOR_TARGET="${LD}"
		LIPO_FOR_TARGET=${LIPO}
		NM_FOR_TARGET="${NM}"
		OBJCOPY_FOR_TARGET="${OBJCOPY}"
		OBJDUMP_FOR_TARGET="${OBJDUMP}"
		RANLIB_FOR_TARGET="${RANLIB}"
		READELF_FOR_TARGET="${READELF}"
		STRIP_FOR_TARGET="${STRIP}"
		WINDRES_FOR_TARGET="${WINDRES}"
		WINDMC_FOR_TARGET="${WINDMC}"
	fi

	if use_if_iuse bundle-binutils ; then
		AR_FOR_TARGET="${AR_FOR_TARGET-binutils/ar}"
		AS_FOR_TARGET="${AS_FOR_TARGET-gas/as-new}"
		DLLTOOL_FOR_TARGET="${DLLTOOL_FOR_TARGET-binutils/dlltool}"
		LD_FOR_TARGET="${LD_FOR_TARGET-ld/ld-new}"
		NM_FOR_TARGET="${NM_FOR_TARGET-binutils/nm-new}"
		OBJCOPY_FOR_TARGET="${OBJCOPY_FOR_TARGET-binutils/objcopy}"
		OBJDUMP_FOR_TARGET="${OBJDUMP_FOR_TARGET-binutils/objdump}"
		RANLIB_FOR_TARGET="${RANLIB_FOR_TARGET-binutils/ranlib}"
		READELF_FOR_TARGET="${READELF_FOR_TARGET-binutils/readelf}"
		STRIP_FOR_TARGET="${STRIP_FOR_TARGET-binutils/strip-new}"
		WINDRES_FOR_TARGET="${WINDRES_FOR_TARGET-binutils/windres}"
		WINDMC_FOR_TARGET="${WINDMC_FOR_TARGET-binutils/windmc}"
	fi
}

# To be defined eventually

# BUILD -m flags, STAGE1_CFLAGS need to be filtered based on what CBUILD toolchain supports,
# BOOT_CFLAGS needs filtering based on current package version support.
# These will be passed in STAGE1_CFLAGS and/or BOOT_CFLAGS when building the compiler.
toolchain_gcc_setup_build_mopts() {
	: "${MCPU_FOR_BUILD:=}"
	: "${MARCH_FOR_BUILD:=}"
	: "${MTUNE_FOR_BUILD:=}"
	: "${MABI_FOR_BUILD:=}"
	: "${MFPU_FOR_BUILD:=}"
	: "${MFLOAT_FOR_BUILD:=}"
}

toolchain_gcc_setup_target_mopts() {
	# TARGET -m flags, need to be filtered based on what current package version supports
	# They will be passed as --with-<flagname>=<value> to configure.
	: "${MCPU_FOR_TARGET:=}"
	: "${MCPU32_FOR_TARGET:=}"
	: "${MCPU64_FOR_TARGET:=}"
	: "${MARCH_FOR_TARGET:=}"
	: "${MARCH32_FOR_TARGET:=}"
	: "${MARCH64_FOR_TARGET:=}"
	: "${MTUNE_FOR_TARGET:=}"
	: "${MTUNE32_FOR_TARGET:=}"
	: "${MTUNE64_FOR_TARGET:=}"
	: "${MABI_FOR_TARGET:=}"
	: "${MFPU_FOR_TARGET:=}"
	: "${MFLOAT_FOR_TARGET:=}"
}




##
# ABI handling
##
# These imported from gentoo's toolchain.eclass -- they should change, as the presumptions don't hold for cross-build normally
toolchain_gcc_setup_abi() {
	if ! toolchain_gcc_is_crosscompiler ; then
		: ${ABI:=${DEFAULT_ABI}}
		: ${TARGET_ABI:=${ABI}}
		: ${TARGET_MULTILIB_ABIS:=${MULTILIB_ABIS}}
		: ${TARGET_DEFAULT_ABI:=${DEFAULT_ABI}}
	fi
}

toolchain_gcc_setup_flags() {
	# Gcc flag for various stages

	#STAGE1_CFLAGS - Used to build stage1 of new compiler using existing compiler. Also applies to non-bootstrap builds.
	#BOOT_CFLAGS - Used to build new compiler against previous bootstrap stage compiler.

	if ! toolchain_gcc_is_crossbuild ; then
		CFLAGS_FOR_BUILD="${CFLAGS_FOR_BUILD-${CFLAGS}}"
		CXXFLAGS_FOR_BUILD="${CXXFLAGS_FOR_BUILD-${CXXFLAGS}}"
		LDFLAGS_FOR_BUILD="${LDFLAGS_FOR_BUILD-${LDFLAGS}}"
	fi

	if ! toolchain_gcc_is_crosscompiler ; then
		CFLAGS_FOR_TARGET="${CFLAGS_FOR_TARGET-${CFLAGS}}"
		CXXFLAGS_FOR_TARGET="${CXXFLAGS_FOR_TARGET-${CXXFLAGS}}"
		LDFLAGS_FOR_TARGET="${LDFLAGS_FOR_TARGET-${LDFLAGS}}"
	fi
}





### THE FOLLOWING NEED REWRITES ###

toolchain_gcc_pkg_setup() {
	[[ "$(declare -p TOOLCHAIN_GCC_CONF 2> /dev/null)" =~ "declare -a" ]] || declare -a -x TOOLCHAIN_GCC_CONF

	# Capture -march -mcpu and -mtune options to pass to build later.
	MARCH="$(printf -- "${CFLAGS}" | sed -rne 's/.*-march="?([-_[:alnum:]]+).*/\1/p')"
	MCPU="$(printf -- "${CFLAGS}" | sed -rne 's/.*-mcpu="?([-_[:alnum:]]+).*/\1/p')"
	MTUNE="$(printf -- "${CFLAGS}" | sed -rne 's/.*-mtune="?([-_[:alnum:]]+).*/\1/p')"
	MFPU="$(printf -- "${CFLAGS}" | sed -rne 's/.*-mfpu="?([-_[:alnum:]]+).*/\1/p')"
	einfo "Got CFLAGS: ${CFLAGS}"
	einfo "Got GCC_BUILD_CFLAGS: ${GCC_BUILD_CFLAGS}"
	einfo "MARCH: ${MARCH}"
	einfo "MCPU ${MCPU}"
	einfo "MTUNE: ${MTUNE}"
	einfo "MFPU: ${MFPU}"

	# Don't pass cflags/ldflags through.
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	unset LDFLAGS
	unset GCC_SPECS # we don't want to use the installed compiler's specs to build gcc!
	unset LANGUAGES #265283
	#export PREFIX="${TOOLCHAIN_PREFIX:-${EPREFIX}/usr}"
	export PREFIX="${TOOLCHAIN_PREFIX:=${EPREFIX}/usr/toolchains/${CTARGET}-gcc-${GCC_CONFIG_VER}}"
	export EXEC_PREFIX="${TOOLCHAIN_EXEC_PREFIX:-${TOOLCHAIN_PREFIX}/${CHOST}}"
	if false ; then
		unset AR
		unset AS
		unset CC
		unset CXX
		unset GFORTRAN
		unset GOC
		unset DLLTOOL
		unset LD
		unset LIPO
		unset NM
		unset OBJCOPY
		unset OBJDUMP
		unset RANLIB
		unset READELF
		unset STRIP
		unset WINDRES
		unset WINDMC
	fi

	#if toolchain_gcc_is_crosscompiler; then
	#	toolchain_gcc_setup_crosscompiler
	#else
	#	toolchain_gcc_setup_native
	#fi

	#export LIBPATH="${TOOLCHAIN_LIBPATH:-${PREFIX}/lib/gcc-lib/${CTARGET}/${GCC_CONFIG_VER}}"
	#export DATAPATH="${TOOLCHAIN_DATAPATH:-${PREFIX}/share/gcc-data/${CTARGET}/${GCC_CONFIG_VER}}"

	#export INCLUDEPATH="${TOOLCHAIN_INCLUDEPATH:-${LIBPATH}/include}"
	#export STDCXX_INCDIR="${TOOLCHAIN_STDCXX_INCDIR:-${LIBPATH}/include/g++-v${GCC_BRANCH_VER}}"

	export CFLAGS="${GCC_BUILD_CFLAGS:--O2 -pipe}"
	export FFLAGS="$CFLAGS"
	export FCFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"

	# Add bootstrap configs to BUILD_CONFIG based on use flags
	use bootstrap-lto && BUILD_CONFIG="${BUILD_CONFIG:+${BUILD_CONFIG} }bootstrap-lto"
	use bootstrap-O3 && BUILD_CONFIG="${BUILD_CONFIG:+${BUILD_CONFIG} }bootstrap-O3"
	export BUILD_CONFIG

	toolchain_gcc_setup_libc

	use_if_iuse doc || export MAKEINFO="/dev/null"
}

toolchain_gcc_setup_libc() {
	# Set our target libc here for both native and crosscompiler use.
	if [ -z "${TARGET_LIBC}" ] ; then
		case ${CTARGET} in
			*-linux) TARGET_LIBC=no-idea;;
			*-dietlibc) TARGET_LIBC=dietlibc;;
			*-elf|*-eabi) TARGET_LIBC=newlib;;
			*-freebsd*) TARGET_LIBC=freebsd-lib;;
			*-gnu*) TARGET_LIBC=glibc;;
			*-klibc) TARGET_LIBC=klibc;;
			*-musl*) TARGET_LIBC=musl;;
			*-uclibc*) TARGET_LIBC=uclibc;;
			avr*) TARGET_LIBC=avr-libc;;
		esac
	fi
	export TARGET_LIBC
}

toolchain_gcc_setup_crosscompiler() {
		export BINPATH="${TOOLCHAIN_BINPATH:=${PREFIX}/${CHOST}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}}"
		export HOSTLIBPATH="${PREFIX}/${CHOST}/${CTARGET}/lib/${GCC_CONFIG_VER}"
}

toolchain_gcc_setup_native() {
		export BINPATH="${TOOLCHAIN_BINPATH:=${PREFIX}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}}"
}


toolchain_gcc_src_prepare() {

	# Run preperations for dependencies first
	in_iuse system-mathlibs && ! use system-mathlibs && toolchain_gcc_prepare_mathlibs

	# Patch from release to svn branch tip for backports
	[ "x${GCC_SVN_PATCH}" = "x" ] || eapply "${GCC_SVN_PATCH}"

	# Apply gentoo patches
	if [ -n "$GENTOO_PATCHES_VER" ]; then
		einfo "Applying Gentoo patches ..."
		for my_patch in ${GENTOO_PATCHES[*]} ; do
			eapply_gentoo "${my_patch}"
		done
	fi


	# Harden things up:
	toolchain_gcc_prepare_harden
	#toolchain_gcc_is_crosscompiler && toolchain_gcc_prepare_crosscompiler

	if in_iuse multilib && ! use multilib ; then
		_run_function_if_exists toolchain_gcc_prepare_nomultilib
	elif use_if_iuse multiarch || ! in_iuse multiarch && toolchain_gcc_is_crosscompiler ; then
		_run_function_if_exists toolchain_gcc_prepare_multiarch
	else
		_run_function_if_exists toolchain_gcc_prepare_multilib
	fi

	# Ada gnat compiler bootstrap preparation
	use_if_iuse ada && _gcc_prepare_gnat

	# Prepare GDC for d-lang support
	use_if_iuse d && _gcc_prepare_gdc

	# Must be called in src_prepare by EAPI6
	eapply_user
}

toolchain_gcc_prepare_mpfr() {
	if [ -n "${MPFR_PATCH_VER}" ];  then
		[ -f "${MPFR_PATCH_FILE}" ] || die "Couldn't find mpfr patch '${MPFR_PATCH_FILE}"
		pushd "${S}/mpfr" > /dev/null || die "Couldn't change to mpfr source directory."
		patch -N -Z -p1 < "${MPFR_PATCH_FILE}" || die "Failed to apply mpfr patch '${MPFR_PATCH_FILE}'."
		popd > /dev/null
	fi
}


toolchain_gcc_prepare_mathlibs() {
	local mathlib
	for mathlib in gmp mpfr mpc $(in_iuse graphite && usex graphite "isl" "") ; do
		_run_function_if_exists toolchain_gcc_prepare_${mathlib}
	done

}

toolchain_gcc_prepare_crosscompiler() {

	# if we don't tell it where to go, libcc1 stuff ends up in ${ROOT}/usr/lib (or rather dies colliding)
	sed -e 's%cc1libdir = .*%cc1libdir = '"${ROOT}${PREFIX}"'/$(host_noncanonical)/$(target_noncanonical)/lib/$(gcc_version)%' \
		-e 's%plugindir = .*%plugindir = '"${ROOT}${PREFIX}"'/lib/gcc/$(target_noncanonical)/$(gcc_version)/plugin%' \
		-i "${WORKDIR}/${P}/libcc1"/Makefile.{am,in}
	if [[ ${CTARGET} == avr* ]]; then
		sed -e 's%native_system_header_dir=/usr/include%native_system_header_dir=/include%' -i "${WORKDIR}/${P}/gcc/config.gcc"
	fi
}


toolchain_gcc_prepare_harden() {
	local gcc_hard_flags=""

	_run_function_if_exists toolchain_gcc_prepare_harden_${GCCMAJOR}

	# Enable FORTIFY_SOURCE by default
	use_if_iuse default_fortify && eapply_gentoo "$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_default-fortify-source.patch )"

	if use_if_iuse dev_extra_warnings ; then
		eapply_gentoo "$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_default-warn-format-security.patch* )"
		eapply_gentoo "$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_default-warn-trampolines.patch* )"
		if use_if_iuse test ; then
			ewarn "USE=dev_extra_warnings enables warnings by default which are known to break gcc's tests!"
		fi
		einfo "Additional warnings enabled by default, this may break some tests and compilations with -Werror."
	fi

	# Add our hardening CFLAGS to gcc's Makefile.in and include them in GCC_CFLAGS, ALL_CFLAGS, and ALL_CXXFLAGS
	sed -e '/^PICFLAG/a\\n# Hardening CFLAGS\nHARD_CFLAGS = '"${gcc_hard_flags}" \
		-e 's/^GCC_CFLAGS = /&$(HARD_CFLAGS) /' \
		-e 's/^ALL_CFLAGS = /&$(HARD_CFLAGS) /' \
		-e 's/^ALL_CXXFLAGS = /&$(HARD_CFLAGS) /' \
		-i "${S}"/gcc/Makefile.in
}

toolchain_gcc_prepare_harden_6_7() {
	cat "${GENTOO_PATCHES_DIR}/$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_extra-options.patch )" \
		| sed \
			-e '/#ifdef ENABLE_DEFAULT_SSP/,/# endif/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_SSP_ALL/ }' \
			-e '/#define STACK_CHECK_SPEC/,/#define LINK_NOW_SPEC/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_LINK_NOW/ }' \
			-e '/CPP_SPEC/,/CC1_SPEC/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_STACK_CHECK/ }' \
			-e '/#ifndef EXTRA_OPTIONS/,/OPT_fstrict_overflow/ { s/#ifndef EXTRA_OPTIONS/#ifndef SANE_FSTRICT_OVERFLOW/ }' \
		> "${T}/hardening-options.patch"
	eapply "${T}/hardening-options.patch"
	# Selectively enable features from hardening patches
	use_if_iuse ssp_all && gcc_hard_flags+=" -DENABLE_DEFAULT_SSP_ALL"
	use_if_iuse link_now && gcc_hard_flags+=" -DENABLE_DEFAULT_LINK_NOW"
	use_if_iuse sane_strict_overflow || gcc_hard_flags+=" -DSANE_FSTRICT_OVERFLOW"
}

toolchain_gcc_prepare_harden_6() {
	toolchain_gcc_prepare_harden_6_7
}

toolchain_gcc_prepare_harden_7() {
	toolchain_gcc_prepare_harden_6_7
}


toolchain_gcc_prepare_harden_8() {
	# Modify gentoo patch to use our more specific hardening flags.
	cat "${GENTOO_PATCHES_DIR}/$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_extra-options.patch )" \
		| sed \
			-e '/^+#ifdef ENABLE_ESP$/,/^+#define DEFAULT_FLAG_SCP 0$/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_SCP/g }' \
			-e '/^+#ifdef EXTRA_OPTIONS$/,/^+#define DEFAULT_FLAG_SCP 0$/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_SCP/g }' \
			-e '/^+#ifdef EXTRA_OPTIONS$/,/^+#define LINK_NOW_SPEC ""$/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_LINK_NOW/g }' \
		> "${T}/hardening-options.patch"
	eapply "${T}/hardening-options.patch"
	# Selectively enable features from hardening patches
	use_if_iuse ssp_all && gcc_hard_flags+=" -DENABLE_DEFAULT_SSP_ALL"
	use_if_iuse link_now && gcc_hard_flags+=" -DENABLE_DEFAULT_LINK_NOW"
	use_if_iuse stack_clash_protection && gcc_hard_flags+=" -DENABLE_DEFAULT_SCP"
}

toolchain_gcc_prepare_multilib() {
	# Force multilib directories to be ../lib{32,64,x32} for linux-64 templates, rather than autodetecting.
	sed -e 's/\(MULTILIB_OSDIRNAMES[[:space:]]*[+:]\?= m\)\([x]\?[63][42]\)=.*/\1\2=..\/lib\2/' -i gcc/config/*/t-linux64
}


toolchain_gcc_conf_append() {
	TOOLCHAIN_GCC_CONF+=( "$@" )
	export TOOLCHAIN_GCC_CONF
}



toolchain_gcc_conf_harden() {
	local myvtvenable="disable"
	use_if_iuse vtv && myvtvenable="enable"

	local myconf=(
		$(in_iuse pie && use_enable pie default-pie)
		$(in_iuse ssp && use_enable ssp default-ssp)
		$(in_iuse libssp && use_enable libssp)
		--${myvtvenable}-vtable-verify
		--${myvtvenable}-libvtv
	)
	toolchain_gcc_conf_append "${myconf[@]}"

	# If we don't have libssp flag enabled, assume the libc provides ssp libs.
	use_if_iuse libssp || export gcc_cv_libc_provides_ssp=yes

}


toolchain_gcc_conf_crossbuild() {
	local myconf=(
		--build=${CBUILD}
		--host=${CHOST}
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}


###
##
## LIBC HANDLING
##
###

## libc checks

_toolchain_libc_status() {
	local my_target_libc="${1:-${TARGET_LIBC}}"
	local my_libc_cat="sys-libs"

	# Allow forcefully overriding libc status using env variable TOOLCHAIN_FORCE_LIBC_STATUS
	if [ -n "${TOOLCHAIN_FORCE_LIBC_STATUS}" ] ; then printf -- '%s' "${TOOLCHAIN_FORCE_LIBC_STATUS}" ; return ; fi

	toolchain_gcc_is_crosscompiler && my_libc_cat="${CATEGORY}"

	local my_cp="${my_libc_cat}/${my_target_libc}"

	if has_version "${my_cp}[-headers-only]" ; then
		printf -- 'installed'
	elif has_version "${my_cp}[headers-only]" ; then
		printf -- 'headers-only'
	else
		printf -- 'none'
	fi
}

_toolchain_has_libc_headers_only() {
	[ "$(_toolchain_libc_status)" = "headers-only" ]
}

_toolchain_has_libc_installed() {
	[ "$(_toolchain_libc_status)" = "installed" ]
}

_toolchain_has_libc_headers() {
	[ "$(_toolchain_libc_status)" != "none" ]
}

_toolchain_has_libc_none() {
	[ "$(_toolchain_libc_status)" = "none" ]
}

# These probably belong in full-toolchain-specific eclasses that are included based on which complete toolchain is being built

toolchain_gcc_conf_for_newlib() {
	local myconf=(
		--with-newlib
		--without-headers
		--disable-shared
		--disable-threads
		--disable-libgomp
	)
	toolchain_gcc_conf_append "${myconf[@]}"
	export TOOLCHAIN_GCC_TARGET="all-gcc target-newlib all"
}

toolchain_gcc_conf_for_glibc() {
	local myconf=(
		--enable-__cxa_atexit
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}


## libc configuraiton

toolchain_gcc_conf_nolibc() {
	local myconf=(
		--disable-shared
		--disable-libatomic
		--disable-threads
		--without-headers
		--disable-libstdcxx
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}

toolchain_gcc_conf_libc_headers_only() {
	local myconf=(
		--disable-shared
		--disable-libatomic
		--disable-libstdcxx
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}



toolchain_gcc_conf_native() {
	local myconf=()
	if use_if_iuse newlib ; then
		toolchain_gcc_conf_for_newlib
	elif _toolchain_has_libc_none ; then
		toolchain_gcc_conf_nolibc
	elif _toolchain_has_libc_headers_only ; then
		toolchain_gcc_conf_libc_headers_only
	else
		myconf=(
			--enable-threads=posix
			--enable-__cxa_atexit
			--enable-libstdcxx-time
			$(in_iuse openmp && use_enable openmp libgomp)
			--enable-bootstrap
			#--enable-shared
		)
	fi

	toolchain_gcc_conf_append "${myconf[@]}"
}

toolchain_gcc_conf_crosscompiler() {
	local myconf=()
	if use_if_iuse newlib ; then
		toolchain_gcc_conf_for_newlib
	elif _toolchain_has_libc_none ; then
		toolchain_gcc_conf_nolibc
	elif _toolchain_has_libc_headers_only ; then
		toolchain_gcc_conf_libc_headers_only
	else
		myconf=(
			--enable-poison-system-directories
		)
	fi

	# If we have at least headers for libc installed, set sysroot path
	! use_if_iuse newlib && _toolchain_has_libc_headers && myconf+=( --with-sysroot=${PREFIX}/${CTARGET} )

	toolchain_gcc_conf_append "${myconf[@]}"
}



# 32 bit ARM
toolchain_gcc_conf_arch_arm() {
	# Skip the rest if not an arm target
	[[ ${CTARGET} == arm* ]] || return

	local conf_gcc_arm=()
	local arm_arch=${CTARGET%%-*}
	local a
	# Remove trailing endian variations first: eb el be bl b l
	for a in e{b,l} {b,l}e b l ; do
		if [[ ${arm_arch} == *${a} ]] ; then
			arm_arch=${arm_arch%${a}}
			break
		fi
	done

	# Convert armv7{a,r,m} to armv7-{a,r,m}
	[[ ${arm_arch} == armv7? ]] && arm_arch=${arm_arch/7/7-}

	# See if this is a valid --with-arch flag
	if (srcdir=${S}/gcc target=${CTARGET} with_arch=${arm_arch};
		. "${srcdir}"/config.gcc) &>/dev/null
	then
		conf_gcc_arm+=( --with-arch=${arm_arch} )
	fi

	# Enable hardvfp
	local float="hard"
	local default_fpu=""

	case "${CTARGET}" in
		*[-_]softfloat[-_]*) float="soft" ;;
		*[-_]softfp[-_]*) float="softfp" ;;
		armv[56]*) default_fpu="vfpv2" ;;
		armv7ve*) default_fpu="vfpv4-d16" ;;
		armv7*) default_fpu="vfpv3-d16" ;;
		amrv8*) default_fpu="fp-armv8" ;;
	esac
	
	conf_gcc_arm+=( --with-float=$float )
	[ -z "${MFPU}" ] && [ -n "${default_fpu}" ] && conf_gcc_arm+=( --with-fpu=${default_fpu} )

	toolchain_gcc_conf_append "${conf_gcc_arm[@]}"
}

# avr
toolchain_gcc_conf_arch_avr() {
	local myconf=(
		--disable-__cxa_atexit
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}

# PPC & RS/6000
toolchain_gcc_conf_arch_rs6000() {
	local myconf=(
		--enable-secureplt
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}

# Check target configuration options / extract values from gcc/config.gcc script
# Passes input vars of form: <var>=<value>
# Prints listed output vars of form <var> (no =*)
toolchain_gcc_config_gcc() {
	local my_in_vars=()
	local my_out_vars=()
	while [ $# -gt 0 ] ; do
		case "$1" in
			*=*) my_in_vars+=( "${1}" ) ;;
			*) my_out_vars+=( "${1}" ) ;;
		esac
		shift
	done
	( eval "${my_in_vars[@]}" ; . gcc/config.gcc || exit 1 ; for v in "${my_out_vars[@]}" ; do eval "printf -- '%s' \${${v}}" ; done )
}


toolchain_gcc_conf_arch() {
	local my_gcc_cpu_type="$(toolchain_gcc_config_gcc target="${CTARGET}" cpu_type)"

	[ -n "${my_gcc_cpu_type}" ] || die "Can not determine gcc's cpu_type for target '${CTARGET}'!"
	_run_function_if_exists toolchain_gcc_conf_arch_${my_gcc_cpu_type}

}

toolchain_gcc_conf_multiarch() {
	local myconf=(
		--enable-multiarch
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}

toolchain_gcc_conf_nomultiarch() {
	local myconf=(
		--disable-multiarch
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}

toolchain_gcc_conf_multilib() {
	local myconf=(
		--enable-multilib
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}

toolchain_gcc_conf_nomultilib() {
	local myconf=(
		--disable-multilib
	)
	toolchain_gcc_conf_append "${myconf[@]}"
}


toolchain_gcc_conf_checking() {
	# 'extra' check must be the same between stage1 and rest of build or it will cause failures, bail out with message if mismatched.
	case "${GCC_STAGE1_CHECKS_LIST}" in
		*extra*) case "${GCC_CHECKS_LIST}" in *extra*) : ;; *) die 'Check "extra" enabled in GCC_STAGE1_CHECKS_LIST but not GCC_CHECKS_LIST will cause failures. Please fix mismatch.' ;; esac ;;
		*) case "${GCC_CHECKS_LIST}" in *extra*) die 'Check "extra" enabled in GCC_CHECKS_LIST but not GCC_STAGE1_CHECKS_LIST will cause failures. Please fix mismatch.'  ;; *) : ;; esac ;;
	esac

	[ -n "${GCC_STAGE1_CHECKS_LIST}" ] && toolchain_gcc_conf_append "--enable-stage1-checking=${GCC_STAGE1_CHECKS_LIST}"
	[ -n "${GCC_CHECKS_LIST}" ] && toolchain_gcc_conf_append "--enable-checking=${GCC_STAGE1_CHECKS_LIST}"
}

toolchain_gcc_conf_languages() {
	# Determine language support:
	local conf_gcc_lang=()
	local GCC_LANG="c,c++"
	if use_if_iuse objc; then
		GCC_LANG+=",objc"
		use_if_iuse objc-gc && conf_gcc_lang+=( --enable-objc-gc )
		use_if_iuse objc++ && GCC_LANG+=",obj-c++"
	fi

	use_if_iuse fortran && GCC_LANG+=",fortran" || conf_gcc_lang+=( --disable-libquadmath )

	use_if_iuse go && GCC_LANG+=",go"

	if use_if_iuse ada ; then
		GCC_LANG+=",ada"
		conf_gcc_lang+=(
			CC=${GNATBOOT}/bin/gcc
			CXX=${GNATBOOT}/bin/g++
			AR=${GNATBOOT}/bin/gcc-ar
			AS=as
			LD=ld
			NM=${GNATBOOT}/bin/gcc-nm
			RANLIB=${GNATBOOT}/bin/gcc-ranlib
		)
	fi

	use_if_iuse d && GCC_LANG+=",d"

	# Enable LTO 'language'
	use_if_iuse lto && GCC_LANG+=",lto"

	conf_gcc_lang+=( --enable-languages=${GCC_LANG} )

	toolchain_gcc_conf_append "${conf_gcc_lang[@]}"

}

toolchain_gcc_src_configure() {

	# Configure the languages we support
	toolchain_gcc_conf_languages

	# Configure for cross-building if needed
	toolchain_gcc_is_crossbuild && toolchain_gcc_conf_crossbuild

	# Confiure for cross-compiler or native compiler, as appropriate.
	if toolchain_gcc_is_crosscompiler ; then
		toolchain_gcc_conf_crosscompiler
	else
		toolchain_gcc_conf_native
	fi

	# Configure for multilib or nomultilib as requested
	if use_if_iuse multilib ; then
		_run_function_if_exists toolchain_gcc_conf_multilib
	else
		_run_function_if_exists toolchain_gcc_conf_nomultilib
	fi

	# Configure for multiarch if requested or if building a crosscompiler
	if use_if_iuse multiarch || toolchain_gcc_is_crosscompiler ; then
		_run_function_if_exists toolchain_gcc_conf_multiarch
	else
		_run_function_if_exists toolchain_gcc_conf_nomultiarch
	fi

	_run_function_if_exists toolchain_gcc_conf_for_${TARGET_LIBC}

	local branding="Funtoo"
	if use_if_iuse hardened; then
		branding="$branding Hardened ${PVR}"
	else
		branding="$branding ${PVR}"
	fi

	# Set up paths
	local myconf=(
		--prefix=${PREFIX}
		--exec-prefix=${EXEC_PREFIX}
	)
	local blah=(
		--bindir=${BINPATH}
		--libdir=${LIBPATH}/lib
		--includedir=${LIBPATH}/include
		--datadir=${DATAPATH}
		--mandir=${DATAPATH}/man
		--infodir=${DATAPATH}/info
		--with-gxx-include-dir=${STDCXX_INCDIR}
		--with-python-dir=${DATAPATH/$PREFIX/}/python
	)

	# Set other various config options (needs cleanup later)
	myconf+=(
		$(in_iuse sanitize && use_enable sanitize libsanitizer)
		$(in_iuse pch && usex pch "" "--disable-libstdcxx-pch")
		$(in_iuse graphite && usex graphite "--disable-isl-version-check" "")
		--enable-clocale=gnu
		--disable-werror
		$(in_iuse lto && use_enable lto)
		--with-bugurl="http://bugs.funtoo.org"
		--with-pkgversion="${branding}"
	)
	
	use_if_iuse system-zlib && myconf+=( --with-system-zlib )

	# Set --build, --host, --target values as appropriate depending on if we're crossbuilding, building a crosscompiler, or crossbuilding a crosscompiler
	if toolchain_gcc_is_canadiancross ; then
		myconf+=(
			--build=${CBUILD}
			--host=${CHOST}
			--target=${CTARGET}
		)
	elif toolchain_gcc_is_crossbuild ; then
		myconf+=(
			--build=${CBUILD}
			--host=${CHOST}
		)
	elif toolchain_gcc_is_crosscompiler ; then
		myconf+=(
			--host=${CHOST}
			--target=${CTARGET}
		)
	fi


	if use_if_iuse bundle-binutils ; then
		myconf+=(
			--with-gnu-ld
			#--enable-gold
			--enable-ld=default
			--with-gnu-as
		)
	fi

	# Set default build configs if defined.
	[ -n "${BUILD_CONFIG}" ] && myconf+=( --with-build-config="${BUILD_CONFIG}" )

	# Configure internal self-checking
	toolchain_gcc_conf_checking


	# This needs rewriting to account for host/build/target correctly
	use generic_host || myconf+=(
		${MARCH_FOR_TARGET:+--with-arch=${MARCH_FOR_TARGET}}
		${MCPU_FOR_TARGET:+--with-cpu=${MCPU_FOR_TARGET}}
		${MTUNE_FOR_TARGET:+--with-tune=${MTUNE_FOR_TARGET}}
		${MFPU_FOR_TARGET:+--with-fpu=${MFPU_FOR_TARGET}}
	)

	# Configure arch-specific options
	toolchain_gcc_conf_arch

	# Configure multilingual support
	if use_if_iuse nls ; then
		myconf+=( --enable-nls )
		in_iuse system-gettext && ! use system-gettext && myconf+=( --with-included-gettext )
	else
		myconf+=( --disable-nls )
	fi

	# Add the above conf to our TOOLCHAIN_GCC_CONF
	toolchain_gcc_conf_append "${myconf[@]}"


	# Set our compilation target and bootstrapping.
	if [ -n "${TOOLCHAIN_GCC_TARGET}" ] ; then
		:
	elif use_if_iuse bootstrap ; then
		TOOLCHAIN_GCC_TARGET="bootstrap"
		toolchain_gcc_conf_append "--enable-bootstrap"
	elif use_if_iuse bootstrap-profiled ; then
		TOOLCHAIN_GCC_TARGET="profiledbootstrap"
		toolchain_gcc_conf_append "--enable-bootstrap"
	elif use_if_iuse bootstrap-lto || use_if_iuse bootstrap-O3 || use_if_iuse bootstrap ; then
		TOOLCHAIN_GCC_TARGET="bootstrap"
		toolchain_gcc_conf_append "--enable-bootstrap"
	else
		TOOLCHAIN_GCC_TARGET="all"
		toolchain_gcc_conf_append "--disable-bootstrap"
	fi

	export TOOLCHAIN_GCC_TARGET

	# Run the configuration step
	printf -- '%s\n' "../gcc/configure" "${TOOLCHAIN_GCC_CONF[@]}"
	cd ${WORKDIR}/objdir && env -i PATH="${PATH}" ../gcc/configure "${TOOLCHAIN_GCC_CONF[@]}" || die "configure fail"

	# Run post-configure cleanups for crosscompilers
	toolchain_gcc_is_crosscompiler && toolchain_gcc_postconf_crosscompiler
}


toolchain_gcc_postconf_crosscompiler() {
	# Is this really just for crosscompiles, or is it needed for native arm builds too?
	if use_if_iuse arm ; then
		sed -i "s/none-/${CHOST%%-*}-/g" ${WORKDIR}/objdir/Makefile || die
	fi
}

toolchain_gcc_src_compile_target() {
	(	unset ABI P
		export LIBPATH="${LIBPATH}"
		env -i PATH="${PATH}" make ${1} || die "Failed to build target '${1}'."
	)
}

toolchain_gcc_src_compile() {
	cd "${WORKDIR}/objdir"

	toolchain_gcc_src_compile_target ${TOOLCHAIN_GCC_TARGET:-${TOOLCHAIN_GCC_TARGET_DEFAULT:-all}}
}

toolchain_gcc_src_test() {

	cd "${WORKDIR}/objdir"
	unset ABI
	local tests_failed=0
	if toolchain_gcc_is_crosscompiler ; then
		ewarn "Running tests on simulator for cross-compiler not yet supported by this ebuild."
	else
		( ulimit -s 65536 && ${MAKE:-make} ${MAKEOPTS} LIBPATH="${ED%/}/${LIBPATH}" -k check RUNTESTFLAGS="-v -v -v" 2>&1 | tee ${T}/make-check-log ) || tests_failed=1
		"../${S##*/}/contrib/test_summary" 2>&1 | tee "${T}/gcc-test-summary.out"
		[ ${tests_failed} -eq 0 ] || die "make -k check failed"
	fi
}

