# Distributed under the terms of the GNU General Public License v2

# See README.txt for usage notes.

EAPI=5

inherit multilib-build eutils pax-utils toolchain-enable

RESTRICT="strip"
FEATURES=${FEATURES/multilib-strict/}

IUSE="ada +cxx go +fortran objc objc++ objc-gc openmp" # languages
IUSE="$IUSE test nls vanilla doc multilib altivec libssp +ssp +pie +pch hardened graphite sanitize dev_extra_warnings" # other stuff

SLOT="${PV}"

# Version of archive before patches.
GCC_ARCHIVE_VER="7.3.0"

# GCC release archive
GCC_A="gcc-${GCC_ARCHIVE_VER}.tar.xz"

# Backported fixes from gcc svn tree
GCC_SVN_PATCH="gcc-${GCC_ARCHIVE_VER}-svn259627.patch"

# Gentoo patcheset
GENTOO_PATCH_VER="1.2"
GENTOO_GCC_PATCH_VER="${GCC_ARCHIVE_VER}"
GENTOO_PATCH_A="gcc-${GENTOO_GCC_PATCH_VER}-patches-${GENTOO_PATCH_VER}.tar.bz2"
# This is fixed by the svn patch
EPATCH_EXCLUDE="91_all_bmi-i386-PR-target-81763.patch"

# Math libs
GMP_VER="6.1.2"
GMP_EXTRAVER=""
MPFR_VER="4.0.1"
MPC_VER="1.1.0"

# Graphite support:
CLOOG_VER="0.18.4"
ISL_VER="0.16.1"

SRC_URI="mirror://gnu/gcc/gcc-${GCC_ARCHIVE_VER}/${GCC_A}"
SRC_URI="$SRC_URI http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz"
SRC_URI="$SRC_URI http://www.mpfr.org/mpfr-${MPFR_VER}/mpfr-${MPFR_VER}.tar.xz"
SRC_URI="$SRC_URI mirror://gnu/gmp/gmp-${GMP_VER}${GMP_EXTRAVER}.tar.xz"
SRC_URI="$SRC_URI mirror://funtoo/gcc/${GENTOO_PATCH_A}"

# Graphite support:
SRC_URI="$SRC_URI graphite? ( http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-${CLOOG_VER}.tar.gz http://isl.gforge.inria.fr/isl-${ISL_VER}.tar.xz )"

# Ada Support:
GNAT32="gnat-gpl-2014-x86-linux-bin.tar.gz"
GNAT64="gnat-gpl-2017-x86_64-linux-bin.tar.gz"
SRC_URI="$SRC_URI ada? ( amd64? ( mirror://funtoo/gcc/${GNAT64} ) x86? ( mirror://funtoo/gcc/${GNAT32} ) )"

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"
KEYWORDS=""

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

	if [ -n $GENTOO_PATCH_VER ]; then
		unpack ${GENTOO_PATCH_A}
	fi

	if use ada && use amd64; then
		unpack $GNAT64 || die "ada setup failed"
	elif use ada && use x86; then
		unpack $GNAT32 || die "ada setup failed"
	fi

	cd $S
	mkdir ${WORKDIR}/objdir
}

p_apply() {
	einfo "Applying ${1##*/}..."
	patch -p1 < $1 > /dev/null || die "Failed applying $1"
}

src_prepare() {
	p_apply "${FILESDIR}/${GCC_SVN_PATCH}"
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

		cat "${FILESDIR}"/gcc-4.6.4-fix-libgcc-s-path-with-vsrl.patch | patch -p1 || die "patch fail"

		if ! use dev_extra_warnings ; then
			EPATCH_EXCLUDE+=" 11_all_default-warn-format-security.patch"
			EPATCH_EXCLUDE+=" 12_all_default-warn-trampolines.patch"
		elif use test ; then
			ewarn "USE=dev_extra_warnings enables warnings by default which are known to break gcc's tests!"
		else
			einfo "Additional warnings enabled by default, this may break some tests and compilations with -Werror."
		fi

		is_crosscompile && EPATCH_EXCLUDE+=" 05_all_gcc-spec-env.patch"
		if [ -n "$GENTOO_PATCH_VER" ]; then
			EPATCH_MULTI_MSG="Applying Gentoo patches ..." \
			EPATCH_SUFFIX="patch" \
			epatch "${WORKDIR}"/patch
		fi

		# Hardened patches
		if use hardened; then
			local gcc_hard_flags="-DEXTRA_OPTIONS"


			sed -e '/^ALL_CFLAGS/iHARD_CFLAGS = ' \
				-e 's|^ALL_CFLAGS = |ALL_CFLAGS = $(HARD_CFLAGS) |' \
				-i "${S}"/gcc/Makefile.in

			sed -e '/^ALL_CXXFLAGS/iHARD_CFLAGS = ' \
				-e 's|^ALL_CXXFLAGS = |ALL_CXXFLAGS = $(HARD_CFLAGS) |' \
				-i "${S}"/gcc/Makefile.in

			sed -i -e "/^HARD_CFLAGS = /s|=|= ${gcc_hard_flags} |" "${S}"/gcc/Makefile.in || die
		fi
	fi

	# Ada gnat compiler bootstrap preparation
	if use ada && use amd64; then
		make -C ${WORKDIR}/${GNAT64%%.*} ins-all prefix=${S}/gnatboot > /dev/null || die "ada preparation failed"
		find ${S}/gnatboot -name ld -exec mv -v {} {}.old \;
	elif use ada && use x86; then
		make -C ${WORKDIR}/${GNAT32%%.*} ins-all prefix=${S}/gnatboot > /dev/null || die "ada preparation failed"
		find ${S}/gnatboot -name ld -exec mv -v {} {}.old \;
	fi
}

src_configure() {
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
		confgcc+=" --disable-bootstrap --enable-poision-system-directories"
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
		confgcc+=" --disable-libgomp"
	else
		confgcc+=" --enable-bootstrap --enable-shared --enable-threads=posix $(use_enable openmp libgomp)"
	fi
	[[ -n ${CBUILD} ]] && confgcc+=" --build=${CBUILD}"
	# Determine language support:
	local GCC_LANG="c,c++"
	if use objc; then
		GCC_LANG+=",objc"
		use objc-gc && confgcc+=" --enable-objc-gc"
		use objc++ && GCC_LANG+=",obj-c++"
	fi
	use fortran && GCC_LANG+=",fortran" || confgcc+=" --disable-libquadmath"
	use go && GCC_LANG+=",go"
	if use ada; then
		GCC_LANG+=",ada"
		export PATH="${S}/gnatboot/bin:${PATH}"
	fi
	confgcc+=" $(use_enable openmp libgomp)"
	confgcc+=" --enable-languages=${GCC_LANG} --disable-libgcj"
	confgcc+=" $(use_enable hardened esp)"
	confgcc+=" $(use_enable sanitize libsanitizer)"
	confgcc+=" $(use_enable pie default-pie)"
	confgcc+=" $(use_enable ssp default-ssp)"
	! use pch && confgcc+=" --disable-libstdcxx-pch"
	use graphite && confgcc+=" --disable-isl-version-check"

	use libssp || export gcc_cv_libc_provides_ssp=yes

	# ARM
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
		local arm_arch_without_dash=${arm_arch}
		[[ ${arm_arch} == armv7? ]] && arm_arch=${arm_arch/7/7-}
		# See if this is a valid --with-arch flag
		if (srcdir=${S}/gcc target=${CTARGET} with_arch=${arm_arch};
			. "${srcdir}"/config.gcc) &>/dev/null
		then
			confgcc+=" --with-arch=${arm_arch}"
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
						confgcc+=" --with-fpu=vfp"
					;;
					armv7*)
						realfpu=$( echo ${CFLAGS} | sed 's/.*mfpu=\([^ ]*\).*/\1/')
						if [[ "$realfpu" == "$CFLAGS" ]] ;then
							# if sed fails to extract, then it's not set, use default:
							confgcc+=" --with-fpu=vfpv3-d16"
						else
							confgcc+=" --with-fpu=${realfpu}"
						fi
					;;
				esac
			fi
			float="hard"
		fi
		confgcc+=" --with-float=$float"
	fi

	local branding="Funtoo"
	if use hardened; then
		branding="$branding Hardened ${PVR}"
	else
		branding="$branding ${PVR}"
	fi

	confgcc+=" --with-python-dir=${DATAPATH/$PREFIX/}/python"
	use nls && confgcc+=" --enable-nls --without-included-gettext" || confgcc+=" --disable-nls"

	P= cd ${WORKDIR}/objdir && ../gcc-${PV}/configure \
		$(use_enable libssp) \
		$(use_enable multilib) \
		--enable-version-specific-runtime-libs \
		--enable-libmudflap \
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
		--with-system-zlib \
		--enable-obsolete \
		--disable-werror \
		--enable-secureplt \
		--enable-lto \
		$(use_with graphite cloog) \
		--with-bugurl=http://bugs.funtoo.org \
		--with-pkgversion="$branding" \
		--enable-stage1-checking=yes \
		--enable-checking=release \
		$confgcc \
		|| die "configure fail"

	#	--with-mpfr-include=${S}/mpfr/src \
	#	--with-mpfr-lib=${WORKDIR}/objdir/mpfr/src/.libs \
	# The --with-mpfr* lines above are used so that gcc-4.6.4 can find mpfr-3.1.2.
	# It can find 2.4.2 with no problem automatically but needs help with newer versions
	# due to mpfr dir structure changes. We look for includes in the source directory,
	# and libraries in the build (objdir) directory.

	if use arm ; then
		# Source : https://sourceware.org/bugzilla/attachment.cgi?id=6807
		# Workaround for a problem introduced with GMP 5.1.0.
		# If configured by gcc with the "none" host & target, it will result in undefined references
		# to '__gmpn_invert_limb' during linking.
		# Should be fixed by next version of gcc.
		sed -i "s/none-/${arm_arch_without_dash}-/" ${WORKDIR}/objdir/Makefile || die
	fi

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
		cp -r "${cxx_mandir}"/man? "${D}/${DATAPATH}"/man/
	fi
	has noinfo ${FEATURES} \
		&& rm -r "${D}/${DATAPATH}"/info \
		|| prepinfo "${DATAPATH}"
	has noman ${FEATURES} \
		&& rm -r "${D}/${DATAPATH}"/man \
		|| prepman "${DATAPATH}"
}

src_install() {
	S=$WORKDIR/objdir; cd $S

# PRE-MAKE INSTALL SECTION:

	# from toolchain eclass:
	# Do allow symlinks in private gcc include dir as this can break the build
	find gcc/include*/ -type l -delete

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
	find "${D}" -name install-tools -prune -type d -exec rm -rf "{}" \;
	# This one comes with binutils
	find "${D}" -name libiberty.a -delete
	# prune empty dirs left behind
	find "${D}" -depth -type d -delete 2>/dev/null
	# ownership fix:
	chown -R root:0 "${D}"${LIBPATH} 2>/dev/null

	linkify_compiler_binaries
	tasteful_stripping
	if is_crosscompile; then
		rm -rf "${D}"/usr/share/{man,info}
		rm -rf "${D}"${DATAPATH}/{man,info}
	else
		find "${D}/${LIBPATH}" -name "*.py" -type f -exec rm "{}" \;
		doc_cleanups
		exeinto "${DATAPATH}"
		doexe "${FILESDIR}"/c{89,99} || die
	fi

	# replace gcc_movelibs - currently handles only libcc1:

	rm ${D}/usr/$(get_libdir)/*.la
	mv ${D}/usr/$(get_libdir)/* ${D}${LIBPATH}/

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
			rm -f "${ROOT}"/etc/env.d/gcc/config-${CTARGET}
			rm -f "${ROOT}"/etc/env.d/??gcc-${CTARGET}
			rm -f "${ROOT}"/usr/bin/${CTARGET}-{gcc,{g,c}++}{,32,64}
		fi
		return 0
	fi
}

pkg_postinst() {
	if is_crosscompile ; then
		return
	fi

	# hack from gentoo - should probably be handled better:
	cp "${ROOT}/${DATAPATH}"/c{89,99} "${ROOT}"/usr/bin/ 2>/dev/null

	compiler_auto_enable ${PV} ${CTARGET}
}
