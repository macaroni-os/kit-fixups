# Distributed under the terms of the GNU General Public License v2

# See README.txt for usage notes.

EAPI=6

inherit multilib-build eutils pax-utils git-r3 toolchain-gcc

RESTRICT="strip"
FEATURES=${FEATURES/multilib-strict/}

toolchain_gcc_version_setup

IUSE="ada +cxx d go +fortran objc objc++ objc-gc " # Languages
IUSE="$IUSE test" # Run tests
IUSE="$IUSE doc nls vanilla hardened +multilib +multiarch" # docs/i18n/system flags
IUSE="$IUSE +lto +openmp altivec +graphite pch generic_host" # Optimizations/features flags
# bootstrap-lto is not currently working, disabled
IUSE="$IUSE libssp +ssp +pie" # Base hardening flags
IUSE="$IUSE +default_fortify +link_now +ssp_all vtv" # Extra hardening flags
[ ${GCCMAJOR} -ge 8 ] && IUSE="$IUSE +stack_clash_protection" || IUSE="${IUSE} +sane_strict_overflow" # Stack clash protector added in gcc-8, strict overflow fixup dropped
IUSE="$IUSE sanitize dev_extra_warnings" # Dev flags
IUSE="$IUSE bootstrap-profiled bootstrap-lto bootstrap-O3 +bootstrap"

# Note, system-zlib needs to be enabled for long-double-format multilib on PPC (-be only?)
IUSE="$IUSE system-zlib system-mathlibs +system-gettext bundle-binutils bundle-gdb newlib"

SLOT="${GCC_RELEASE_VER}"

S="${WORKDIR}/gcc"

toolchain_gcc_get_src_uri

SRC_URI="${GCC_SRC_URI}"

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"
KEYWORDS="*"

RDEPEND="
	system-zlib? ( sys-libs/zlib[static-libs,${MULTILIB_USEDEP}] )
	nls? ( system-gettext? ( sys-devel/gettext[static-libs,${MULTILIB_USEDEP}] ) )
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

# Gentoo patcheset
GENTOO_PATCHES_VER="1.1"
GENTOO_GCC_PATCHES_VER="${GCC_ARCHIVE_VER}"
GENTOO_PATCHES_DIR="${FILESDIR}/gentoo-patches/gcc-${GENTOO_GCC_PATCHES_VER}-patches-${GENTOO_PATCHES_VER}"
GENTOO_PATCHES=(
	#01_all_default-fortify-source.patch
	#02_all_default-warn-format-security.patch
	#03_all_default-warn-trampolines.patch
	04_all_default-ssp-fix.patch
	05_all_alpha-mieee-default.patch
	06_all_ia64_note.GNU-stack.patch
	07_all_i386_libgcc_note.GNU-stack.patch
	08_all_libiberty-asprintf.patch
	09_all_libiberty-pic.patch
	10_all_nopie-all-flags.patch
	#11_all_extra-options.patch
	12_all_pr55930-dependency-tracking.patch
	13_all_sh-drop-sysroot-suffix.patch
	14_all_ia64-TEXTREL.patch
	15_all_disable-systemtap-switch.patch
	16_all_sh_textrel-on-libitm.patch
	17_all_m68k-textrel-on-libgcc.patch
	18_all_respect-build-cxxflags.patch
	19_all_libgfortran-Werror.patch
	20_all_libgomp-Werror.patch
	21_all_libitm-Werror.patch
	22_all_libatomic-Werror.patch
	23_all_libbacktrace-Werror.patch
	24_all_libsanitizer-Werror.patch
	25_all_libstdcxx-no-vtv.patch
	26_all_overridable_native.patch
)


pkg_setup() {
	toolchain_gcc_pkg_setup
}


src_unpack() {
	toolchain_gcc_src_unpack
	mkdir "${WORKDIR}/objdir"
}

eapply_gentoo() {
	eapply "${GENTOO_PATCHES_DIR}/${1}"
}

src_prepare() {
	toolchain_gcc_src_prepare
}

src_configure() {
	toolchain_gcc_src_configure
}

src_compile() {
	toolchain_gcc_src_compile
}

src_test() {
	toolchain_gcc_src_test
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

	if toolchain_gcc_is_crosscompiler; then
		echo "CTARGET=\"${CTARGET}\"" >> ${gcc_envd_file}
	fi
}

linkify_compiler_binaries() {
	dodir ${PREFIX}/bin
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
			if ! toolchain_gcc_is_crosscompiler; then
				ln -sf ${CTARGET}-${x} ${x}
				dosym ${BINPATH}/${CTARGET}-${x} ${PREFIX}/bin/${x}-${GCC_CONFIG_VER}
			fi
			# Create version-ed symlinks
			dosym ${BINPATH}/${CTARGET}-${x} ${PREFIX}/bin/${CTARGET}-${x}-${GCC_CONFIG_VER}
		fi

		if [[ -f ${CTARGET}-${x}-${GCC_CONFIG_VER} ]] ; then
			rm -f ${CTARGET}-${x}-${GCC_CONFIG_VER}
			ln -sf ${CTARGET}-${x} ${CTARGET}-${x}-${GCC_CONFIG_VER}
		fi
	done
}

tasteful_stripping() {
	# Now do the fun stripping stuff
	[[ ! toolchain_gcc_is_crosscompiler ]] && \
		env RESTRICT="" CHOST=${CHOST} prepstrip "${D}${BINPATH}" ; \
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
	if toolchain_gcc_is_crosscompiler || ! use doc || has noinfo ${FEATURES} ; then
		rm -r "${D}/${DATAPATH}"/info
	else
		prepinfo "${DATAPATH}"
	fi

	# Strip man files too if 'noman' feature is set.
	if toolchain_gcc_is_crosscompiler || has noman ${FEATURES} ; then
		rm -r "${D}/${DATAPATH}"/man
	else
		prepman "${DATAPATH}"
	fi
}

cross_toolchain_env_setup() {

	# old xcompile bashrc stuff here
	dosym /etc/localtime /usr/${CTARGET}/etc/localtime
	for file in /usr/lib/gcc/${CTARGET}/${GCC_CONFIG_VER}/libstdc*; do
		dosym "$file" "/usr/${CTARGET}/lib/$(basename $file)"
	done
	mkdir -p /etc/revdep-rebuild
	insinto "/etc/revdep-rebuild"
	string="SEARCH_DIRS_MASK=\"/usr/${CTARGET} "
	for dir in /usr/lib/gcc/${CTARGET}/*; do
		string+="$dir "
	done
	for dir in /usr/lib64/gcc/${CTARGET}/*; do
		string+="$dir "
	done
	string="${string%?}"
	string+='"' 
	if [[ -e /etc/revdep-rebuild/05cross-${CTARGET} ]] ; then
		string+=" $(cat /etc/revdep-rebuild/05cross-${CTARGET}|sed -e 's/SEARCH_DIRS_MASK=//')"
	fi
	printf "$string">05cross-${CTARGET}
	doins 05cross-${CTARGET}
}
				
src_install() {
	S=$WORKDIR/objdir; cd $S

# PRE-MAKE INSTALL SECTION:

	# Don't allow symlinks in private gcc include dir as this can break the build
	( set +f ; find gcc/include*/ -type l -delete 2>/dev/null )

	# Remove generated headers, as they can cause things to break
	# (ncurses, openssl, etc).
	while read x; do
		grep -q 'It has been auto-edited by fixincludes from' "${x}" \
			&& echo "Removing auto-generated header: $x" \
			&& rm -f "${x}"
	done < <(find gcc/include*/ -name '*.h')

# MAKE INSTALL SECTION:

	env -i PATH="${PATH}" make -j1 DESTDIR="${D}" install || die
	return

# POST MAKE INSTALL SECTION:
	if toolchain_gcc_is_crosscompiler; then
		cross_toolchain_env_setup
	else
		# Basic sanity check
		local EXEEXT
		eval $(grep ^EXEEXT= "${WORKDIR}"/objdir/gcc/config.log)
		[[ -r ${D}${BINPATH}/gcc${EXEEXT} ]] || die "gcc not found in ${D}"

		# Install compat wrappers
		exeinto "${DATAPATH}"
		( set +f ; doexe "${FILESDIR}"/c{89,99} || die )	
	fi
	
	# Setup env.d entry 
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
	
	# Remove python files in the lib path
	find "${D}/${LIBPATH}" -name "*.py" -type f -exec rm "{}" \; 2>/dev/null
	
	# Remove unwanted docs and prepare the rest for installation
	doc_cleanups
	
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
		einfo -- "Removing extraneous libtool '.la' files from '${PREFIX}/lib*}'."
		rm ${D%/}${PREFIX}/lib{,32,64}/*.la 2>/dev/null
		einfo -- "Relocating libs to '${LIBPATH}':"
		for l in "${D%/}${PREFIX}"/lib{,32,64}/* ; do
			[ -f "${l}" ] || continue
			mydir="${l%/*}" ; myfile="${l##*/}"
			einfo -- "Moving '${myfile}' from '${mydir#${D}}' to '${LIBPATH}'."
			cd "${mydir}" && mv "${myfile}" "${D}${LIBPATH}/${myfile}" 2>/dev/null || die
		done
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
		export QA_EXECSTACK="${PREFIX#/}/lib*/go/*/*.gox"
		export QA_WX_LOAD="${PREFIX#/}/lib*/go/*/*.gox"
	fi

	# Disable RANDMMAP so PCH works.
	[[ ! toolchain_gcc_is_crosscompiler ]] && \
		pax-mark -r "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}/cc1" ; \
		pax-mark -r "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}/cc1plus"
}

pkg_postrm() {
	# clean up the cruft left behind by cross-compilers
	if toolchain_gcc_is_crosscompiler ; then
		if [[ -z $(ls "${ROOT}etc/env.d/gcc"/${CTARGET}* 2>/dev/null) ]] ; then
			( set +f
				rm -f "${ROOT}etc/env.d/gcc"/config-${CTARGET} 2>/dev/null
				rm -f "${ROOT}etc/env.d"/??gcc-${CTARGET} 2>/dev/null
				rm -f "${ROOT}usr/bin"/${CTARGET}-{gcc,{g,c}++}{,32,64} 2>/dev/null
			)
		fi
		return 0
	fi
}

pkg_postinst() {
	if toolchain_gcc_is_crosscompiler; then
			mkdir -p "${ROOT}etc/env.d"
			cat > "${ROOT}etc/env.d/05gcc-${CTARGET}" <<- EOF
				PATH=${BINPATH}
				ROOTPATH=${BINPATH}
			EOF
	fi

	# hack from gentoo - should probably be handled better:
	( set +f ; cp "${ROOT}${DATAPATH}"/c{89,99} "${ROOT}${PREFIX}/bin/" 2>/dev/null )

	PATH="${BINPATH}:${PATH}"
	export PATH
	compiler_auto_enable ${PV} ${CTARGET}
}



