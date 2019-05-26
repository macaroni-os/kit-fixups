# Distributed under the terms of the GNU General Public License v2

# See README.txt for usage notes.

EAPI=6

inherit multilib-build eutils pax-utils toolchain-enable git-r3

RESTRICT="strip"
FEATURES=${FEATURES/multilib-strict/}

GCC_MAJOR="${PV%%.*}"

IUSE="ada +cxx d go +fortran objc objc++ objc-gc " # Languages
IUSE="$IUSE test" # Run tests
IUSE="$IUSE doc nls vanilla hardened multilib" # docs/i18n/system flags
IUSE="$IUSE openmp altivec graphite +pch lto-bootstrap generic_host" # Optimizations/features flags
IUSE="$IUSE libssp +ssp" # Base hardening flags
IUSE="$IUSE +pie +vtv link_now ssp_all" # Extra hardening flags
[ ${GCC_MAJOR} -ge 8 ] && IUSE="$IUSE stack_clash_protection" # Stack clash protector added in gcc-8
IUSE="$IUSE sanitize dev_extra_warnings" # Dev flags


# Handle internal self checking options
CHECKS_RELEASE="assert runtime"
CHECKS_YES="${CHECKS_RELEASE} misc tree gc rtlflag"
CHECKS_EXTRA="$( [ ${GCC_MAJOR} -ge 8 ] && printf -- "extra" )"
CHECKS_VALGRIND="valgrind"
CHECKS_ALL="${CHECKS_YES} df fold gcac rtl ${CHECKS_EXTRA}"

for _check in no release yes all ${CHECKS_ALL} ${CHECKS_VALGRIND}; do
	IUSE="${IUSE} checking_${_check} stage1_checking_${_check}"
done



SLOT="${PV}"

# Version of archive before patches.
GCC_ARCHIVE_VER="5.5.0"
GCC_SVN_REV=""

# GCC release archive
GCC_A="gcc-${GCC_ARCHIVE_VER}.tar.xz"
SRC_URI="mirror://gnu/gcc/gcc-${GCC_ARCHIVE_VER}/${GCC_A}"

# Backported fixes from gcc svn tree
GCC_SVN_PATCH=""
#GCC_SVN_PATCH="${FILESDIR}/svn-patches/gcc-${GCC_ARCHIVE_VER}-to-svn-${GCC_SVN_REV}.patch"

# Gentoo patcheset
GENTOO_PATCHES_VER="1.9"
GENTOO_GCC_PATCHES_VER="${GCC_ARCHIVE_VER}"
GENTOO_GCC_PATCHES_VER="5.4.0"
GENTOO_PATCHES_DIR="${FILESDIR}/gentoo-patches/gcc-${GENTOO_GCC_PATCHES_VER}-patches-${GENTOO_PATCHES_VER}"
GENTOO_PATCHES=(
	05_all_gcc-spec-env.patch
	09_all_default-ssp.patch
	10_all_default-fortify-source.patch
	#11_all_default-warn-format-security.patch
	#12_all_default-warn-trampolines.patch
	20_all_msgfmt-libstdc++-link.patch
	24_all_boehm-gc-execinfo.patch
	25_all_alpha-mieee-default.patch
	26_all_alpha-asm-mcpu.patch
	29_all_arm_armv4t-default.patch
	34_all_ia64_note.GNU-stack.patch
	34_all_libjava-classpath-locale-sort.patch
	38_all_sh_pr24836_all-archs.patch
	42_all_superh_default-multilib.patch
	50_all_libiberty-asprintf.patch
	51_all_libiberty-pic.patch
	52_all_netbsd-Bsymbolic.patch
	53_all_libitm-no-fortify-source.patch
	67_all_gcc-poison-system-directories.patch
	70_all_gcc-5-pr546752.patch
	71_all_gcc-5-march-native-pr67310.patch
	74_all_gcc5_isl-dl.patch
	77_all_gcc-5-pr65958.patch
	78_all_gcc-5-pr71442.patch
	90_all_pr55930-dependency-tracking.patch
	91_all_compatibility_fix_with_perl_5.26.patch
	92_all_asan-signal_h.patch
	#93_all_ucontext-to-ucontext_t.patch
	#94_all_no-sigaltstack.patch
	#95_all_libjava-ucontext.patch
	#96_all_libsanitizer-avoidustat.h-glibc-2.28-part-1.patch
	#97_all_libsanitizer-avoidustat.h-glibc-2.28-part-2.patch
)

# Math libraries:
GMP_VER="6.1.2"
GMP_EXTRAVER=""
SRC_URI="$SRC_URI mirror://gnu/gmp/gmp-${GMP_VER}${GMP_EXTRAVER}.tar.xz"

MPFR_VER="4.0.1"
MPFR_PATCH_VER="1"
SRC_URI="$SRC_URI http://www.mpfr.org/mpfr-${MPFR_VER}/mpfr-${MPFR_VER}.tar.xz"
MPFR_PATCH_FILE="${MPFR_PATCH_VER:+${FILESDIR}/mpfr/mpfr-${MPFR_VER}_to_${MPFR_VER}-p${MPFR_PATCH_VER}.patch}"

MPC_VER="1.1.0"
SRC_URI="$SRC_URI http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz"

# Graphite support:
CLOOG_VER="0.18.4"
ISL_VER="0.20"
SRC_URI="$SRC_URI graphite? ( http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-${CLOOG_VER}.tar.gz http://isl.gforge.inria.fr/isl-${ISL_VER}.tar.xz )"

# Ada Support:
GNAT32="gnat-gpl-2014-x86-linux-bin.tar.gz"
GNAT64="gnat-gpl-2017-x86_64-linux-bin.tar.gz"
SRC_URI="$SRC_URI ada? ( amd64? ( mirror://funtoo/gcc/${GNAT64} ) x86? ( mirror://funtoo/gcc/${GNAT32} ) )"

# D support
DLANG_REPO_URI="https://github.com/D-Programming-GDC/GDC.git"
DLANG_BRANCH="gdc-${GCC_MAJOR}-stable"
DLANG_COMMIT_DATE="2018-08-26"
DLANG_CHECKOUT_DIR="${WORKDIR}/gdc"

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"
KEYWORDS="*"

RDEPEND="
	sys-libs/zlib[static-libs,${MULTILIB_USEDEP}]
	nls? ( sys-devel/gettext[static-libs,${MULTILIB_USEDEP}] )
	virtual/libiconv[${MULTILIB_USEDEP}]
	objc-gc? ( >=dev-libs/boehm-gc-7.6[static-libs,${MULTILIB_USEDEP}] )
	!sys-devel/gcc:5.3
"
DEPEND="${RDEPEND}
	>=sys-devel/bison-1.875
	>=sys-devel/flex-2.5.4
	>=${CATEGORY}/binutils-2.18
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	test? ( dev-util/dejagnu sys-devel/autogen )"

PDEPEND=">=sys-devel/gcc-config-1.5 >=sys-devel/libtool-2.4.3"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

tc-is-cross-compiler() {
	[[ ${CBUILD:-${CHOST}} != ${CHOST} ]]
}

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

pkg_setup() {
	# Capture -march -mcpu and -mtune options to pass to build later.
	MARCH="$(printf -- "${CFLAGS}" | sed -rne 's/.*-march="?([-_[:alnum:]]+).*/\1/p')"
	MCPU="$(printf -- "${CFLAGS}" | sed -rne 's/.*-mcpu="?([-_[:alnum:]]+).*/\1/p')"
	MTUNE="$(printf -- "${CFLAGS}" | sed -rne 's/.*-mtune="?([-_[:alnum:]]+).*/\1/p')"
	einfo "Got CFLAGS: ${CFLAGS}"
	einfo "MARCH: ${MARCH}"
	einfo "MCPU ${MCPU}"
	einfo "MTUNE: ${MTUNE}"

	# Don't pass cflags/ldflags through.
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	unset LDFLAGS
	unset GCC_SPECS # we don't want to use the installed compiler's specs to build gcc!
	unset LANGUAGES #265283
	PREFIX=/usr
	CTARGET=${CTARGET:-${CHOST}}
	[[ ${CATEGORY} == cross-* ]] && CTARGET=${CATEGORY/cross-}
	GCC_BRANCH_VER=${SLOT}
	GCC_CONFIG_VER=${PV}
	DATAPATH=${PREFIX}/share/gcc-data/${CTARGET}/${GCC_CONFIG_VER}
	if is_crosscompile; then
		BINPATH=${PREFIX}/${CHOST}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}
		CFLAGS="-O2 -pipe"
		FFLAGS="$CFLAGS"
		FCFLAGS="$CFLAGS"
		CXXFLAGS="$CFLAGS"
	else
		BINPATH=${PREFIX}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}
	fi
	LIBPATH=${PREFIX}/lib/gcc/${CTARGET}/${GCC_CONFIG_VER}
	STDCXX_INCDIR=${LIBPATH}/include/g++-v${GCC_BRANCH_VER}

	use doc || export MAKEINFO="true"
}

src_unpack() {
	unpack $GCC_A
	mv "gcc-${GCC_ARCHIVE_VER}" "${S}"
	( unpack mpc-${MPC_VER}.tar.gz && mv ${WORKDIR}/mpc-${MPC_VER} ${S}/mpc ) || die "mpc setup fail"
	( unpack mpfr-${MPFR_VER}.tar.xz && mv ${WORKDIR}/mpfr-${MPFR_VER} ${S}/mpfr ) || die "mpfr setup fail"
	( unpack gmp-${GMP_VER}${GMP_EXTRAVER}.tar.xz && mv ${WORKDIR}/gmp-${GMP_VER} ${S}/gmp ) || die "gmp setup fail"

	if use graphite; then
		( unpack cloog-${CLOOG_VER}.tar.gz && mv ${WORKDIR}/cloog-${CLOOG_VER} ${S}/cloog ) || die "cloog setup fail"
		( unpack isl-${ISL_VER}.tar.xz && mv ${WORKDIR}/isl-${ISL_VER} ${S}/isl ) || die "isl setup fail"
	fi

	# GNAT ada support
	if use ada ; then
		if use amd64; then
			unpack $GNAT64 || die "ada setup failed"
		elif use x86; then
			unpack $GNAT32 || die "ada setup failed"
		else
			die "GNAT ada setup failed, only x86 and amd64 currently supported by this ebuild. Patches welcome!"
		fi
	fi

	# gdc D support
	if use d ; then
		O_EGIT_BRANCH="${EGIT_BRANCH}"
		O_EGIT_COMMIT="${EGIT_COMMIT}"
		O_EGIT_COMMIT_DATE="${EGIT_COMMIT_DATE}"
		EGIT_BRANCH="${DLANG_BRANCH}"
		EGIT_COMMIT="${DLANG_COMMIT}"
		EGIT_COMMIT_DATE="${DLANG_COMMIT_DATE}"
		git-r3_fetch "${DLANG_REPO_URI}"
		git-r3_checkout "${DLANG_REPO_URI}" "${DLANG_CHECKOUT_DIR}"
		EGIT_BRANCH="${O_EGIT_BRANCH}"
		EGIT_COMMIT="${O_EGIT_COMMIT}"
		EGIT_COMMIT_DATE="${O_EGIT_COMMIT_DATE}"
	fi

	cd $S
	mkdir ${WORKDIR}/objdir
}

eapply_gentoo() {
	eapply "${GENTOO_PATCHES_DIR}/${1}"
}

src_prepare() {
	# Run preperations for dependencies first
	_gcc_prepare_mpfr

	# Patch from release to svn branch tip for backports
	[ "x${GCC_SVN_PATCH}" = "x" ] || eapply "${GCC_SVN_PATCH}"

	( use vanilla && use hardened ) \
		&& die "vanilla and hardened USE flags are incompatible. Disable one of them"

	# For some reason, when upgrading gcc, the gcc Makefile will install stuff
	# like crtbegin.o into a subdirectory based on the name of the currently-installed
	# gcc version, rather than *our* gcc version. Manually fix this:

	sed -i -e "s/^version :=.*/version := ${GCC_CONFIG_VER}/" ${S}/libgcc/Makefile.in || die

	if ! use vanilla; then

		# Prevent libffi from being installed
		sed -i -e 's/\(install.*:\) install-.*recursive/\1/' "${S}"/libffi/Makefile.in || die
		sed -i -e 's/\(install-data-am:\).*/\1/' "${S}"/libffi/include/Makefile.in || die

		# We use --enable-version-specific-libs with ./configure. This
		# option is designed to place all our libraries into a sub-directory
		# rather than /usr/lib*.  However, this option, even through 4.8.0,
		# does not work 100% correctly without a small fix for
		# libgcc_s.so. See: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=32415.
		# So, we apply a small patch to get this working:

		eapply "${FILESDIR}/gcc-4.6.4-fix-libgcc-s-path-with-vsrl.patch" || die "patch fail"

		if use dev_extra_warnings ; then
			eapply_gentoo "11_all_default-warn-format-security.patch"
			eapply_gentoo "12_all_default-warn-trampolines.patch"
			if use test ; then
				ewarn "USE=dev_extra_warnings enables warnings by default which are known to break gcc's tests!"
			fi
			einfo "Additional warnings enabled by default, this may break some tests and compilations with -Werror."
		fi

		if [ -n "$GENTOO_PATCHES_VER" ]; then
			einfo "Applying Gentoo patches ..."
			for my_patch in ${GENTOO_PATCHES[*]} ; do
				eapply_gentoo "${my_patch}"
			done
		fi

		use lto-bootstrap && eapply "${FILESDIR}/Fix-bootstrap-miscompare-with-LTO-bootstrap-PR85571.patch"

		# Harden things up:
		_gcc_prepare_harden
	fi
	# Ada gnat compiler bootstrap preparation
	use ada && _gcc_prepare_gnat

	# Prepare GDC for d-lang support
	use d && _gcc_prepare_gdc

	# Must be called in src_prepare by EAPI6
	eapply_user
}

_gcc_prepare_mpfr() {
	if [ -n "${MPFR_PATCH_VER}" ];  then
		[ -f "${MPFR_PATCH_FILE}" ] || die "Couldn't find mpfr patch '${MPFR_PATCH_FILE}"
		pushd "${S}/mpfr" > /dev/null || die "Couldn't change to mpfr source directory."
		patch -N -Z -p1 < "${MPFR_PATCH_FILE}" || die "Failed to apply mpfr patch '${MPFR_PATCH_FILE}'."
		popd > /dev/null
	fi
}

_gcc_prepare_harden() {
	local gcc_hard_flags=""
	[ ${GCC_MAJOR} -eq 7 ] && _gcc_prepare_harden_7
	[ ${GCC_MAJOR} -eq 8 ] && _gcc_prepare_harden_8
	
	# Selectively enable features from hardening patches
	use ssp_all && gcc_hard_flags+=" -DENABLE_DEFAULT_SSP_ALL"
	use link_now && gcc_hard_flags+=" -DENABLE_DEFAULT_LINK_NOW"


	sed -e '/^ALL_CFLAGS/iHARD_CFLAGS = ' \
		-e 's|^ALL_CFLAGS = |ALL_CFLAGS = $(HARD_CFLAGS) |' \
		-i "${S}"/gcc/Makefile.in

	sed -e '/^ALL_CXXFLAGS/iHARD_CFLAGS = ' \
		-e 's|^ALL_CXXFLAGS = |ALL_CXXFLAGS = $(HARD_CFLAGS) |' \
		-i "${S}"/gcc/Makefile.in

	sed -i -e "/^HARD_CFLAGS = /s|=|= ${gcc_hard_flags} |" "${S}"/gcc/Makefile.in || die
}

_gcc_prepare_harden_7() {
		# Fix signed integer overflow insanity:
		sed -e '/{ OPT_LEVELS_2_PLUS, OPT_fstrict_overflow, NULL, 1 }/ d' -i gcc/opts.c
		# Prevent breakage if -fstack-check has been set to default on
		sed -e 's/$(INHIBIT_LIBC_CFLAGS)/-fstack-check=no &/' -i libgcc/Makefile.in
		# Allow -fstack-protector-all to be enabled by default with appropriate defines
		sed -e 's/#ifdef ENABLE_DEFAULT_SSP/&\n# ifdef ENABLE_DEFAULT_SSP_ALL\n#  define DEFAULT_FLAGS_SSP 2\n# endif/' -i gcc/defaults.h
}

_gcc_prepare_harden_8() {
		# Modify gentoo patch to use our more specific hardening flags.
		[ ${GCC_MAJOR} -ge 8 ] && cat "${GENTOO_PATCHES_DIR}/55_all_extra-options.patch" | sed -e 's/EXTRA_OPTIONS/ENABLE_DEFAULT_LINK_NOW/g' -e 's/ENABLE_ESP/ENABLE_DEFAULT_SCP/g' > "${T}/55_all_hardening-options.patch"
		eapply "${T}/55_all_hardening-options.patch"
		use stack_clash_protection && gcc_hard_flags+=" -DENABLE_DEFAULT_SCP"
}

_gcc_prepare_gnat() {
	if use amd64; then
		einfo "Preparing gnat64 for ada:"
		make -C ${WORKDIR}/${GNAT64%%.*} ins-all prefix=${S}/gnatboot > /dev/null || die "ada preparation failed"
		find ${S}/gnatboot -name ld -exec mv -v {} {}.old \;
	elif use x86; then
		einfo "Preparing gnat32 for ada:"
		make -C ${WORKDIR}/${GNAT32%%.*} ins-all prefix=${S}/gnatboot > /dev/null || die "ada preparation failed"
		find ${S}/gnatboot -name ld -exec mv -v {} {}.old \;
	else
		die "GNAT ada setup failed, only x86 and amd64 currently supported by this ebuild. Patches welcome!"
	fi
}

_gcc_prepare_gdc() {
	pushd "${DLANG_CHECKOUT_DIR}" > /dev/null || die "Could not change to GDC directory."

		# Apply patches to the patches to account for gentoo patches modifications to configure changing line numbers
		local _gdc_gentoo_compat_patch="${FILESDIR}/lang/d/${PF}-gdc-gentoo-compatibility.patch"
		[ -f "${_gdc_gentoo_compat_patch}" ] && eapply "$_gdc_gentoo_compat_patch"

		./setup-gcc.sh ../gcc-${PV} || die "Could not setup GDC."
	popd > /dev/null
}

gcc_conf_lang_opts() {
	# Determine language support:
	local conf_gcc_lang=""
	local GCC_LANG="c,c++"
	if use objc; then
		GCC_LANG+=",objc"
		use objc-gc && conf_gcc_lang+=" --enable-objc-gc"
		use objc++ && GCC_LANG+=",obj-c++"
	fi

	use fortran && GCC_LANG+=",fortran" || conf_gcc_lang+=" --disable-libquadmath"

	use go && GCC_LANG+=",go"

	use ada && GCC_LANG+=",ada"

	use d && GCC_LANG+=",d"

	conf_gcc_lang+=" --enable-languages=${GCC_LANG} --disable-libgcj"

	printf -- "${conf_gcc_lang}"
}

gcc_conf_arm_opts() {
	# ARM
	local conf_gcc_arm=""
	if [[ ${CTARGET} == arm* ]] ; then
		local a arm_arch=${CTARGET%%-*}
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
			conf_gcc_arm+=" --with-arch=${arm_arch}"
		fi

		# Enable hardvfp
		local float
		local CTARGET_TMP=${CTARGET:-${CHOST}}
		if [[ ${CTARGET_TMP//_/-} == *-softfloat-* ]] ; then
			float="soft"
		elif [[ ${CTARGET_TMP//_/-} == *-softfp-* ]] ; then
			float="softfp"
		else
			if [[ ${CTARGET} == armv[67]* ]]; then
				case ${CTARGET} in
					armv6*)
						conf_gcc_arm+=" --with-fpu=vfp"
					;;
					armv7*)
						realfpu=$( echo ${CFLAGS} | sed 's/.*mfpu=\([^ ]*\).*/\1/')
						if [[ "$realfpu" == "$CFLAGS" ]] ;then
							# if sed fails to extract, then it's not set, use default:
							conf_gcc_arm+=" --with-fpu=vfpv3-d16"
						else
							conf_gcc_arm+=" --with-fpu=${realfpu}"
						fi
					;;
				esac
			fi
			float="hard"
		fi
		conf_gcc_arm+=" --with-float=$float"
	fi

	printf -- "${conf_gcc_arm}"
}

src_configure() {

	# Setup additional paths as needed before we start.
	use ada && export PATH="${S}/gnatboot/bin:${PATH}"

	local confgcc
	if is_crosscompile || tc-is-cross-compiler; then
		confgcc+=" --target=${CTARGET}"
	fi
	if is_crosscompile; then
		case ${CTARGET} in
			*-linux)			needed_libc=no-idea;;
			*-dietlibc)			needed_libc=dietlibc;;
			*-elf|*-eabi)		needed_libc=newlib;;
			*-freebsd*)			needed_libc=freebsd-lib;;
			*-gnu*)				needed_libc=glibc;;
			*-klibc)			needed_libc=klibc;;
			*-musl*)			needed_libc=musl;;
			*-uclibc*)			needed_libc=uclibc;;
		esac
		confgcc+=" --disable-bootstrap --enable-poison-system-directories"
		if ! has_version ${CATEGORY}/${needed_libc}; then
			# we are building with libc that is not installed:
			confgcc+=" --disable-shared --disable-libatomic --disable-threads --without-headers"
		elif built_with_use --hidden --missing false ${CATEGORY}/${needed_libc} crosscompile_opts_headers-only; then
			# libc installed, but has USE="crosscompile_opts_headers-only" to only install headers:
			confgcc+=" --disable-shared --disable-libatomic --with-sysroot=${PREFIX}/${CTARGET}"
		else
			# libc is installed:
			confgcc+=" --with-sysroot=${PREFIX}/${CTARGET}"
		fi
	else
		confgcc+=" --enable-bootstrap --enable-shared --enable-threads=posix"
	fi
	[[ -n ${CBUILD} ]] && confgcc+=" --build=${CBUILD}"
	confgcc+=" $(if ! is_crosscompile ; then use_enable openmp libgomp ; else printf -- "--disable-libgomp"; fi)"
	confgcc+=" $(use_enable sanitize libsanitizer)"
	confgcc+=" $(use_enable pie default-pie)"
	confgcc+=" $(use_enable ssp default-ssp)"
	! use pch && confgcc+=" --disable-libstdcxx-pch"
	#use graphite && confgcc+=" --disable-isl-version-check"

	use vtv && confgcc+=" --enable-vtable-verify --enable-libvtv"

	use libssp || export gcc_cv_libc_provides_ssp=yes

	local branding="Funtoo"
	if use hardened; then
		branding="$branding Hardened ${PVR}"
	else
		branding="$branding ${PVR}"
	fi

	confgcc+=" --with-python-dir=${DATAPATH/$PREFIX/}/python"
	use nls && confgcc+=" --enable-nls --with-included-gettext" || confgcc+=" --disable-nls"

       use generic_host || confgcc+="${MARCH:+ --with-arch=${MARCH}}${MCPU:+ --with-cpu=${MCPU}}${MTUNE:+ --with-tune=${MTUNE}}"
	P= cd ${WORKDIR}/objdir && ../gcc-${PV}/configure \
		$(use_enable libssp) \
		$(use_enable multilib) \
		--enable-version-specific-runtime-libs \
		--prefix=${PREFIX} \
		--bindir=${BINPATH} \
		--includedir=${LIBPATH}/include \
		--datadir=${DATAPATH} \
		--mandir=${DATAPATH}/man \
		--infodir=${DATAPATH}/info \
		--with-gxx-include-dir=${STDCXX_INCDIR} \
		--enable-libstdcxx-time \
		--enable-__cxa_atexit \
		--enable-clocale=gnu \
		--host=$CHOST \
		--enable-obsolete \
		--disable-werror \
		--enable-libmudflap \
		--enable-secureplt \
		--enable-lto \
		--with-system-zlib \
		$(use_with graphite cloog) \
		--with-bugurl=http://bugs.funtoo.org \
		--with-pkgversion="$branding" \
		$(gcc_checking_opts stage1) $(gcc_checking_opts) \
		$(gcc_conf_lang_opts) $(gcc_conf_arm_opts) $confgcc \
		|| die "configure fail"

}

src_compile() {
	cd $WORKDIR/objdir
	unset ABI

	if is_crosscompile || tc-is-cross-compiler; then
		emake P= LIBPATH="${LIBPATH}" all || die "compile fail"
	else
		emake P= LIBPATH="${LIBPATH}" all || die "compile fail"
		#emake LIBPATH="${LIBPATH}" bootstrap-lean || die "compile fail"
	fi
}

src_test() {
	cd $WORKDIR/objdir
	unset ABI

	if is_crosscompile || tc-is-cross-compiler; then
		ewarn "Running tests on simulator for cross-compiler not yet supported by this ebuild."
	else
		ulimit -s 65536 && emake LIBPATH="${LIBPATH}" -k check RUNTESTFLAGS="-v -v -v" 2>&1 | tee ${T}/make-check-log || die "make -k check failed"
	fi

}

create_gcc_env_entry() {
	dodir /etc/env.d/gcc
	local gcc_envd_base="/etc/env.d/gcc/${CTARGET}-${GCC_CONFIG_VER}"
	local gcc_envd_file="${D}${gcc_envd_base}"
	if [ -z $1 ]; then
		gcc_specs_file=""
	else
		gcc_envd_file="$gcc_envd_file-$1"
		gcc_specs_file="${LIBPATH}/$1.specs"
	fi
	cat <<-EOF > ${gcc_envd_file}
	GCC_PATH="${BINPATH}"
	LDPATH="${LIBPATH}:${LIBPATH}/32"
	MANPATH="${DATAPATH}/man"
	INFOPATH="${DATAPATH}/info"
	STDCXX_INCDIR="${STDCXX_INCDIR##*/}"
	GCC_SPECS="${gcc_specs_file}"
	EOF

	if is_crosscompile; then
		echo "CTARGET=\"${CTARGET}\"" >> ${gcc_envd_file}
	fi
}

linkify_compiler_binaries() {
	dodir /usr/bin
	cd "${D}"${BINPATH}
	# Ugh: we really need to auto-detect this list.
	#	   It's constantly out of date.

	local binary_languages="cpp gcc g++ c++ gcov"
	local gnat_bins="gnat gnatbind gnatchop gnatclean gnatfind gnatkr gnatlink gnatls gnatmake gnatname gnatprep gnatxref"

	use go && binary_languages="${binary_languages} gccgo"
	use fortran && binary_languages="${binary_languages} gfortran"
	use ada && binary_languages="${binary_languages} ${gnat_bins}"
	use d && binary_languages="${binary_languages} gdc"

	for x in ${binary_languages} ; do
		[[ -f ${x} ]] && mv ${x} ${CTARGET}-${x}

		if [[ -f ${CTARGET}-${x} ]] ; then
			if ! is_crosscompile; then
				ln -sf ${CTARGET}-${x} ${x}
				dosym ${BINPATH}/${CTARGET}-${x} /usr/bin/${x}-${GCC_CONFIG_VER}
			fi
			# Create version-ed symlinks
			dosym ${BINPATH}/${CTARGET}-${x} /usr/bin/${CTARGET}-${x}-${GCC_CONFIG_VER}
		fi

		if [[ -f ${CTARGET}-${x}-${GCC_CONFIG_VER} ]] ; then
			rm -f ${CTARGET}-${x}-${GCC_CONFIG_VER}
			ln -sf ${CTARGET}-${x} ${CTARGET}-${x}-${GCC_CONFIG_VER}
		fi
	done
}

tasteful_stripping() {
	# Now do the fun stripping stuff
	env RESTRICT="" CHOST=${CHOST} prepstrip "${D}${BINPATH}"
	env RESTRICT="" CHOST=${CTARGET} prepstrip "${D}${LIBPATH}"
	# gcc used to install helper binaries in lib/ but then moved to libexec/
	[[ -d ${D}${PREFIX}/libexec/gcc ]] && \
		env RESTRICT="" CHOST=${CHOST} prepstrip "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}"
}

doc_cleanups() {
	local cxx_mandir=$(find "${WORKDIR}/objdir/${CTARGET}/libstdc++-v3" -name man)
	if [[ -d ${cxx_mandir} ]] ; then
		# clean bogus manpages #113902
		find "${cxx_mandir}" -name '*_build_*' -exec rm {} \;
		( set +f ; cp -r "${cxx_mandir}"/man? "${D}/${DATAPATH}"/man/ )
	fi

	# Remove info files if we don't want them.
	if ! use doc || has noinfo ${FEATURES} ; then
		rm -r "${D}/${DATAPATH}"/info
	else
		prepinfo "${DATAPATH}"
	fi

	# Strip man files too if 'noman' feature is set.
	if has noman ${FEATURES} ; then
		rm -r "${D}/${DATAPATH}"/man
	else
		prepman "${DATAPATH}"
	fi
}

src_install() {
	S=$WORKDIR/objdir; cd $S

# PRE-MAKE INSTALL SECTION:

	# from toolchain eclass:
	# Do allow symlinks in private gcc include dir as this can break the build
	( set +f ; find gcc/include*/ -type l -delete 2>/dev/null )

	# Remove generated headers, as they can cause things to break
	# (ncurses, openssl, etc).
	while read x; do
		grep -q 'It has been auto-edited by fixincludes from' "${x}" \
			&& echo "Removing auto-generated header: $x" \
			&& rm -f "${x}"
	done < <(find gcc/include*/ -name '*.h')

# MAKE INSTALL SECTION:

	make -j1 DESTDIR="${D}" install || die

# POST MAKE INSTALL SECTION:

	# Basic sanity check
	if ! is_crosscompile; then
		local EXEEXT
		eval $(grep ^EXEEXT= "${WORKDIR}"/objdir/gcc/config.log)
		[[ -r ${D}${BINPATH}/gcc${EXEEXT} ]] || die "gcc not found in ${D}"
	fi

	dodir /etc/env.d/gcc
	create_gcc_env_entry

# CLEANUPS:

	# Punt some tools which are really only useful while building gcc
	find "${D}" -name install-tools -prune -type d -exec rm -rf "{}" \; 2>/dev/null
	# This one comes with binutils
	find "${D}" -name libiberty.a -delete 2>/dev/null
	# prune empty dirs left behind
	find "${D}" -depth -type d -delete 2>/dev/null
	# ownership fix:
	chown -R root:0 "${D}"${LIBPATH} 2>/dev/null

	linkify_compiler_binaries
	tasteful_stripping
	if is_crosscompile; then
		( set +f
			rm -rf "${D%/}/usr/share"/{man,info} 2>/dev/null
			rm -rf "${D}${DATAPATH}"/{man,info} 2>/dev/null
		)
	else
		find "${D}/${LIBPATH}" -name "*.py" -type f -exec rm "{}" \; 2>/dev/null
		doc_cleanups
		exeinto "${DATAPATH}"
		( set +f ; doexe "${FILESDIR}"/c{89,99} || die )
	fi

	# Cleanup undesired libtool archives
	find "${D}" \
		'(' \
			-name 'libstdc++.la' -o -name 'libstdc++fs.la' -o -name 'libsupc++.la' -o \
			-name 'libcc1.la' -o -name 'libcc1plugin.la' -o -name 'libcp1plugin.la' -o \
			-name 'libgomp.la' -o -name 'libgomp-plugin-*.la' -o \
			-name 'libgfortran.la' -o -name 'libgfortranbegin.la' -o \
			-name 'libmpx.la' -o -name 'libmpxwrappers.la' -o \
			-name 'libitm.la' -o -name 'libvtv.la' -o -name 'lib*san.la' \
		')' -type f -delete 2>/dev/null

	# replace gcc_movelibs - currently handles only libcc1:
	( set +f
		rm ${D%/}/usr/lib{,32,64}/*.la 2>/dev/null
		mv ${D%/}/usr/lib{,32,64}/* ${D}${LIBPATH}/ 2>/dev/null
	)

	# the .la files that are installed have weird embedded single quotes around abs
	# paths on the dependency_libs line. The following code finds and fixes them:

	for x in $(find ${D}${LIBPATH} -iname '*.la'); do
		dep="$(cat $x | grep ^dependency_libs)"
		[ "$dep" == "" ] && continue
		inner_dep="${dep#dependency_libs=}"
		inner_dep="${inner_dep//\'/}"
		inner_dep="${inner_dep# *}"
		sed -i -e "s:^dependency_libs=.*$:dependency_libs=\'${inner_dep}\':g" $x || die
	done

	# Don't scan .gox files for executable stacks - false positives
	if use go; then
		export QA_EXECSTACK="usr/lib*/go/*/*.gox"
		export QA_WX_LOAD="usr/lib*/go/*/*.gox"
	fi

	# Disable RANDMMAP so PCH works.
	pax-mark -r "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}/cc1"
	pax-mark -r "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}/cc1plus"
}

pkg_postrm() {
	# clean up the cruft left behind by cross-compilers
	if is_crosscompile ; then
		if [[ -z $(ls "${ROOT}"/etc/env.d/gcc/${CTARGET}* 2>/dev/null) ]] ; then
			( set +f
				rm -f "${ROOT}"/etc/env.d/gcc/config-${CTARGET} 2>/dev/null
				rm -f "${ROOT}"/etc/env.d/??gcc-${CTARGET} 2>/dev/null
				rm -f "${ROOT}"/usr/bin/${CTARGET}-{gcc,{g,c}++}{,32,64} 2>/dev/null
			)
		fi
		return 0
	fi
}

pkg_postinst() {
	if is_crosscompile ; then
		return
	fi

	# hack from gentoo - should probably be handled better:
	( set +f ; cp "${ROOT}/${DATAPATH}"/c{89,99} "${ROOT}"/usr/bin/ 2>/dev/null )

	compiler_auto_enable ${PV} ${CTARGET}
}



# GCC internal self checking options
# Usage: gcc_checking_opts [stage1]
gcc_checking_opts() {
	local stage1="${1}${1:+_}"

	local opts check checks
	# Setting checking_no overrides all other checks
	if use ${stage1}checking_no ; then
		opts="no"
	else
		# Priority is all > yes > release
		if use ${stage1}checking_all ; then
			checks="${CHECKS_ALL}"
		elif use ${stage1}checking_yes ; then
			checks="${CHECKS_YES}"
		elif use ${stage1}checking_release ; then
			checks="${CHECKS_RELEASE}"
		fi

		# Check if explict use flags are set for any valid checks
		for check in ${CHECKS_ALL} ${CHECKS_VALGRIND} ; do
			# Check if the flag is enabled and add to list if not there; force extra to set the same for both scopes.
			if use ${stage1}checking_${check} || ( [ -n "${CHECKS_EXTRA}" ] && [ "${check}" = "extra" ] && ( use stage1_checking_extra || use checking_extra ) ) ; then
				has check "${checks}" || checks="${checks} ${check}"
			fi
		done

		# If no checking has been defined, set defaults
		if [ -z "${checks}" ] ; then
			if [ -n "${stage1}" ] ; then
				checks="${CHECKS_YES}"
			else
				checks="${CHECKS_RELEASE}"
			fi
		fi

		# build our opts string
		for check in ${checks} ; do
			opts="${opts}${opts:+,}${check}"
		done
	fi


	printf -- "--enable-${stage1:+${stage1%_}-}checking=${opts}"
}
