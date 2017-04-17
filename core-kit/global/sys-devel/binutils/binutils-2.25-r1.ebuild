# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit multilib

DESCRIPTION="The official GNU collection of binary linker/assembler tools."
HOMEPAGE="http://www.gnu.org/software/binutils/"

LICENSE="|| ( GPL-3 LGPL-3 )"
SLOT="${PV}"
KEYWORDS="*"
IUSE="cxx multislot multitarget nls static-libs test zlib"

EGIT_COMMIT=69352378c67a71c3f1e41d219035febbd943461c
S=$WORKDIR/binutils-gdb
BVER=${PV}.20150509
SRC_URI="mirror://funtoo/binutils/${PN}-${PV}.20150509.tar.bz2"

RDEPEND=">=sys-devel/binutils-config-3 zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	test? ( dev-util/dejagnu )
	nls? ( sys-devel/gettext )
	sys-devel/flex
	virtual/yacc"

is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

pkg_setup() {
	CTARGET=${CTARGET:-${CHOST}}
	if [[ ${CTARGET} == ${CHOST} ]] ; then
		if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
			CTARGET=${CATEGORY/cross-}
		fi
	fi
	LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${BVER}
	INCPATH=${LIBPATH}/include
	DATAPATH=/usr/share/binutils-data/${CTARGET}/${BVER}
	MY_BUILDDIR=${WORKDIR}/build
	if is_cross ; then
		BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${BVER}
	else
		BINPATH=/usr/${CTARGET}/binutils-bin/${BVER}
	fi
	einfo $LIBPATH
}

src_prepare() {
	# Fix po Makefile generators
	sed -i \
		-e '/^datadir = /s:$(prefix)/@DATADIRNAME@:@datadir@:' \
		-e '/^gnulocaledir = /s:$(prefix)/share:$(datadir):' \
		*/po/Make-in || die "sed po's failed"
}

src_configure() {
	myconf=( --enable-secureplt $(use_with zlib) )
	use cxx && myconf+=( --enable-gold )	
	use nls && myconf+=( --without-included-gettext ) || myconf+=( --disable-nls )
	use multitarget && myconf+=( --enable-targets=all --enable-64-bit-bfd )
	[[ -n ${CBUILD} ]] && myconf+=( --build=${CBUILD} )
	is_cross && myconf+=( --with-sysroot="${EPREFIX}"/usr/${CTARGET} )
	myconf+=(
		--prefix="${EPREFIX}"/usr
		--host=${CHOST}
		--target=${CTARGET}
		--datadir="${EPREFIX}"${DATAPATH}
		--infodir="${EPREFIX}"${DATAPATH}/info
		--mandir="${EPREFIX}"${DATAPATH}/man
		--bindir="${EPREFIX}"${BINPATH}
		--libdir="${EPREFIX}"${LIBPATH}
		--libexecdir="${EPREFIX}"${LIBPATH}
		--includedir="${EPREFIX}"${INCPATH}
		--enable-obsolete
		--enable-shared
		--enable-threads
		--enable-install-libiberty
		--disable-werror
		--with-bugurl="https://bugs.funtoo.org/"
		--with-pkgversion="Funtoo ${PV}"
		$(use_enable static-libs static)
		${EXTRA_ECONF}
		# Disable modules that are in a combined binutils/gdb tree. #490566
		--disable-{gdb,libdecnumber,readline,sim}
		# Strip out broken static link flags.
		# https://gcc.gnu.org/PR56750
		--without-stage1-ldflags
	)
	"${S}"/configure "${myconf[@]}" || die
	# Prevent makeinfo from running in releases:
	sed -i -e '/^MAKEINFO/s:=.*:= true:' Makefile || die
}

src_compile() {
	cd "${MY_BUILDDIR}"
	emake all || die "emake failed"
}

src_test() {
	cd "${MY_BUILDDIR}"
	emake -k check || die "check failed :("
}

src_install() {
	cd "${MY_BUILDDIR}"
	emake DESTDIR="${D}" tooldir="${EPREFIX}${LIBPATH}" install || die
	rm -rf "${ED}"/${LIBPATH}/bin
	use static-libs || find "${ED}" -name '*.la' -delete

	# Newer versions of binutils get fancy with ${LIBPATH} #171905
	cd "${ED}"/${LIBPATH}
	for d in ../* ; do
	[[ ${d} == ../${BVER} ]] && continue
		mv ${d}/* . || die
		rmdir ${d} || die
	done

	# Now we collect everything intp the proper SLOT-ed dirs
	# When something is built to cross-compile, it installs into
	# /usr/$CHOST/ by default ... we have to 'fix' that :)
	if is_cross ; then
		cd "${ED}"/${BINPATH}
		for x in * ; do
			mv ${x} ${x/${CTARGET}-}
		done

		if [[ -d ${ED}/usr/${CHOST}/${CTARGET} ]] ; then
			mv "${ED}"/usr/${CHOST}/${CTARGET}/include "${ED}"/${INCPATH}
			mv "${ED}"/usr/${CHOST}/${CTARGET}/lib/* "${ED}"/${LIBPATH}/
			rm -r "${ED}"/usr/${CHOST}/{include,lib}
		fi
	fi
	insinto ${INCPATH}
	local libiberty_headers=(
		# Not all the libiberty headers.  See libiberty/Makefile.in:install_to_libdir.
		demangle.h
		dyn-string.h
		fibheap.h
		hashtab.h
		libiberty.h
		objalloc.h
		splay-tree.h
	)
	doins "${libiberty_headers[@]/#/${S}/include/}" || die
	if [[ -d ${ED}/${LIBPATH}/lib ]] ; then
		mv "${ED}"/${LIBPATH}/lib/* "${ED}"/${LIBPATH}/
		rm -r "${ED}"/${LIBPATH}/lib
	fi

	# Generate an env.d entry for this binutils
	insinto /etc/env.d/binutils
	cat <<-EOF > "${T}"/env.d
		TARGET="${CTARGET}"
		VER="${BVER}"
		LIBPATH="${EPREFIX}${LIBPATH}"
	EOF
	newins "${T}"/env.d ${CTARGET}-${BVER}

	# Handle documentation
	if ! is_cross ; then
		cd "${S}"
		dodoc README
		docinto bfd
		dodoc bfd/ChangeLog* bfd/README bfd/PORTING bfd/TODO
		docinto binutils
		dodoc binutils/ChangeLog binutils/NEWS binutils/README
		docinto gas
		dodoc gas/ChangeLog* gas/CONTRIBUTORS gas/NEWS gas/README*
		docinto gprof
		dodoc gprof/ChangeLog* gprof/TEST gprof/TODO gprof/bbconv.pl
		docinto ld
		dodoc ld/ChangeLog* ld/README ld/NEWS ld/TODO
		docinto libiberty
		dodoc libiberty/ChangeLog* libiberty/README
		docinto opcodes
		dodoc opcodes/ChangeLog*
	fi
	# Remove shared info pages
	rm -f "${ED}"/${DATAPATH}/info/{dir,configure.info,standards.info}
	# Trim all empty dirs
	find "${ED}" -depth -type d -exec rmdir {} + 2>/dev/null
}

pkg_postinst() {
	# Make sure this ${CTARGET} has a binutils version selected
	[[ -e ${EROOT}/etc/env.d/binutils/config-${CTARGET} ]] && return 0
	binutils-config ${CTARGET}-${BVER}
}
