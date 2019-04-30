# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://anongit.freedesktop.org/git/mesa/mesa.git"

if [[ ${PV} = 9999 ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
fi

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )

inherit meson eutils llvm python-any-r1 pax-utils ${GIT_ECLASS} multilib-minimal

OPENGL_DIR="xorg-x11"

MY_P="${P/_/-}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

if [[ $PV == 9999 ]]; then
	SRC_URI=""
else
	SRC_URI="https://mesa.freedesktop.org/archive/${MY_P}.tar.xz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
fi

LICENSE="MIT"
SLOT="0"

RADEON_CARDS="r100 r200 r300 r600 radeonsi"
INTEL_CARDS="i915 i965"

ALL_DRI_DRIVERS="i915 i965 r100 r200 nouveau swrast"
for card in ${ALL_DRI_DRIVERS% swrast*}; do
	ALL_DRI_CARDS+=" video_cards_${card}"
done


ALL_GALLIUM_DRIVERS="pl111 radeonsi r300 r600 nouveau freedreno vc4 v3d etnaviv imx tegra i915 svga virgl swr swrast"
for card in ${ALL_GALLIUM_DRIVERS% swrast*}; do
	case "$card" in
		etnaviv) card="vivante" ;;
		svga) card="vmware" ;;
		*) : ;;
	esac
	ALL_GALLIUM_CARDS+=" video_cards_${card}"
done


ALL_VULKAN_DRIVERS="amd intel"
ALL_VULKAN_CARDS="video_cards_radeonsi video_cards_i965"

ALL_SWR_ARCHES="avx avx2 knl skx"
IUSE_SWR_CPUFLAGS="cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_avx512er cpu_flags_x86_avx512bw"

IUSE_VIDEO_CARDS="${ALL_DRI_CARDS} ${ALL_GALLIUM_CARDS}"
IUSE_DRIVER_OPTS="i915_classic_driver swrast_classic_driver nouveau_classic_driver"

IUSE_GL="+glvnd +opengl +glx +egl +gles1 +gles2"
IUSE_PLATFORMS="+X +drm wayland +surfaceless android haiku"
IUSE_VULKAN="+vulkan +xlib_lease"
IUSE_CL="opencl +ocl-icd"
IUSE_MEDIA="vaapi vdpau xvmc xa openmax"


IUSE="${IUSE_VIDEO_CARDS}
	${IUSE_DRIVER_OPTS}
	${IUSE_GL}
	${IUSE_VULKAN}
	${IUSE_PLATFORMS}
	${IUSE_CL}
	${IUSE_MEDIA}
	${IUSE_SWR_CPUFLAGS}
	+dri3 +gbm
	+llvm +shader-cache
	osmesa d3d9
	extra-hud sensors
	pax_kernel pic selinux
	debug unwind valgrind
	alternate-path
	test"

REQUIRED_USE_APIS="
	gles1? ( opengl )
	gles2? ( opengl )
	glx? ( X opengl )
	glvnd? ( || ( egl glx ) )
	vulkan? ( X? ( dri3 ) )
"

REQUIRED_USE="
	d3d9?   ( dri3 )
	opencl? (
		llvm
		|| ( ${ALL_GALLIUM_CARDS} )
	)
	vaapi? (
		X
		|| ( video_cards_r600 video_cards_radeonsi video_cards_nouveau )
		video_cards_nouveau? ( !nouveau_classic_driver )

	)
	vdpau? (
		X
		|| ( video_cards_r300 video_cards_r600 video_cards_radeonsi video_cards_nouveau )
		video_cards_nouveau? ( !nouveau_classic_driver )
	)
	xvmc? (
		X
		|| ( video_cards_r600 video_cards_nouveau )
		video_cards_nouveau? ( !nouveau_classic_driver )
	)
	xa? (
		|| ( video_cards_nouveau video_cards_freedreno video_cards_i915 video_cards_vmware )
		video_cards_nouveau? ( !nouveau_classic_driver )
		video_cards_i915? ( !i915_classic_driver )
	)
	openmax? (
		|| ( X drm )
		|| ( video_cards_r600 video_cards_radeonsi video_cards_nouveau )
		video_cards_nouveau? ( !nouveau_classic_driver )
	)



	vulkan? ( || ( ${ALL_VULKAN_CARDS} ) )
	wayland? ( egl gbm )

	!swrast_classic_driver? ( llvm )
	video_cards_swr? ( || ( ${IUSE_SWR_CPUFLAGS} ) )

	video_cards_imx?    ( video_cards_vivante )
	video_cards_tegra? ( video_cards_nouveau !nouveau_classic_driver )
	video_cards_r300?   ( x86? ( llvm ) amd64? ( llvm ) )
	video_cards_radeonsi?   ( llvm egl? ( || ( drm surfaceless ) ) )
	video_cards_pl111? ( video_cards_vc4 )
	video_cards_virgl? ( egl? ( || ( drm surfaceless ) ) )
	video_cards_vivante? ( gbm )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.96"
# keep blocks in rdepend for binpkg
RDEPEND="
	!<x11-base/xorg-server-1.7
	glvnd? ( >=media-libs/libglvnd-0.2.0[${MULTILIB_USEDEP}] )
	>=app-eselect/eselect-opengl-1.3.0
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8[${MULTILIB_USEDEP}]

	X? (
		>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXdamage-1.1.4-r1:=[${MULTILIB_USEDEP}]
		x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
		dri3? (
			>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
			>=x11-base/xcb-proto-1.13:=[${MULTILIB_USEDEP}]
		)
		!dri3? ( >=x11-libs/libxcb-1.9.3:=[${MULTILIB_USEDEP}] )
		>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
		drm? ( >=x11-proto/dri2proto-2.8:=[${MULTILIB_USEDEP}] )
		>=x11-proto/glproto-1.4.14:=[${MULTILIB_USEDEP}]
		xlib_lease? (
			>=x11-libs/libXrandr-1.3:=[${MULTILIB_USEDEP}]
			>=x11-base/xcb-proto-1.13:=[${MULTILIB_USEDEP}]
			>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
		)
	)

	wayland? (
		>=dev-libs/wayland-protocols-1.15
		>=dev-libs/wayland-1.15.0:=[${MULTILIB_USEDEP}]
	)

	sensors? ( sys-apps/lm_sensors[${MULTILIB_USEDEP}] )
	unwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
	llvm? (
		video_cards_radeonsi? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
		video_cards_r600? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
	)
	opencl? (
		dev-libs/ocl-icd
		dev-libs/libclc
		virtual/libelf:0=[${MULTILIB_USEDEP}]
	)
	openmax? (
		>=media-libs/libomxil-bellagio-0.9.3:=[${MULTILIB_USEDEP}]
		x11-misc/xdg-utils
	)
	vaapi? (
		>=x11-libs/libva-1.7.3:=[${MULTILIB_USEDEP}]
		video_cards_nouveau? ( !<=x11-libs/libva-vdpau-driver-0.7.4-r3 )
	)
	vdpau? ( >=x11-libs/libvdpau-1.1:=[${MULTILIB_USEDEP}] )
	xvmc? ( >=x11-libs/libXvMC-1.0.8:=[${MULTILIB_USEDEP}] )

	${LIBDRM_DEPSTRING}[video_cards_freedreno?,video_cards_nouveau?,video_cards_vc4?,video_cards_vivante?,video_cards_vmware?,${MULTILIB_USEDEP}]

	video_cards_i915? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
"
for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )
	"
done

RDEPEND="${RDEPEND}
	video_cards_radeonsi? ( ${LIBDRM_DEPSTRING}[video_cards_amdgpu] )
"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.
#
# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 7.
# 3. Specify LLVM_MAX_SLOT, e.g. 6.
#LLVM_MAX_SLOT=8
LLVM_DEPSTR="
	|| (
		sys-devel/llvm:8[${MULTILIB_USEDEP}]
		sys-devel/llvm:7[${MULTILIB_USEDEP}]
		>=sys-devel/llvm-6.0.1-r1[${MULTILIB_USEDEP}]
	)
	sys-devel/llvm:=[${MULTILIB_USEDEP}]
"
LLVM_DEPSTR_AMDGPU=${LLVM_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
CLANG_DEPSTR=${LLVM_DEPSTR//llvm/clang}
CLANG_DEPSTR_AMDGPU=${CLANG_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
RDEPEND="${RDEPEND}
	llvm? (
		opencl? (
			video_cards_r600? (
				${CLANG_DEPSTR_AMDGPU}
			)
			!video_cards_r600? (
				video_cards_radeonsi? (
					${CLANG_DEPSTR_AMDGPU}
				)
			)
			!video_cards_r600? (
				!video_cards_radeonsi? (
					${CLANG_DEPSTR}
				)
			)
		)
		!opencl? (
			video_cards_r600? (
				${LLVM_DEPSTR_AMDGPU}
			)
			!video_cards_r600? (
				video_cards_radeonsi? (
					${LLVM_DEPSTR_AMDGPU}
				)
			)
			!video_cards_r600? (
				!video_cards_radeonsi? (
					${LLVM_DEPSTR}
				)
			)
		)
	)
"
unset {LLVM,CLANG}_DEPSTR{,_AMDGPU}

DEPEND="${RDEPEND}
	>=dev-util/meson-0.48.1
	${PYTHON_DEPS}
	opencl? (
		>=sys-devel/gcc-4.6
	)
	sys-devel/gettext
	virtual/pkgconfig
	valgrind? ( dev-util/valgrind )
	sys-devel/bison
	sys-devel/flex
	$(python_gen_any_dep ">=dev-python/mako-1.0.7[\${PYTHON_USEDEP}]")
"

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR=${S}

QA_WX_LOAD="
x86? (
	!pic? (
		usr/lib*/libglapi.so.0.0.0
		usr/lib*/libGLESv1_CM.so.1.1.0
		usr/lib*/libGLESv2.so.2.0.0
		usr/lib*/libGL.so.1.2.0
		usr/lib*/libOSMesa.so.8.0.0
	)
)"

llvm_check_deps() {
	local flags=${MULTILIB_USEDEP}

	# Don't use LLVM 6 for radv, it cause hard lockups.
	# This may be fixed with llvm 6.0.1?
	#if use video_cards_radeonsi && use vulkan && [[ ${LLVM_SLOT} == 6 ]] ; then return 1 ; fi

	# SWR doesn't like llvm-7 as of mesa 18.3.0_rc1
	if use video_cards_swr && [ ${LLVM_SLOT} -eq 0 ] ; then return 1 ; fi

	if use video_cards_r600 || use video_cards_radeonsi ; then
		flags+=",llvm_targets_AMDGPU(-)"
	fi

	if use opencl; then
		has_version "sys-devel/clang:${LLVM_SLOT}[${flags}]" || return 1
	fi
	has_version "sys-devel/llvm:${LLVM_SLOT}[${flags}]"
}

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use llvm; then
		llvm_pkg_setup
	fi
	python-any-r1_pkg_setup
}

src_prepare() {
	if [ -d "${FILESDIR}" ] && [ "$(cd "$FILESDIR" && echo "${P}"-*.patch)" != "${P}"'-*.patch' ] ; then
		eapply "${FILESDIR}/${P}"-*.patch
	fi
	[[ ${PV} == 9999 ]] && eautoreconf

	# Fix gl.pc.in when using libglvnd to always link using -lGL
	use glvnd && sed -e 's/-l@GL_LIB@/-lGL/' -i src/mesa/gl.pc.in

	eapply_user

	export OLD_PATH="${PATH}"
}

multilib_src_configure() {
	local myconf

	# Enable shader compilers
	tool_enable glsl
	tool_enable nir

	# swrast drivers
	if use swrast_classic_driver ; then
		dri_enable swrast
	else
		gallium_enable swrast
		# swr only builds on 64bit intel
		if [[ ${ABI} == amd64 ]] ; then
			gallium_enable video_cards_swr swr
		fi
	fi

	# VirGL driver
	gallium_enable video_cards_virgl virgl

	# Intel cards
	if use video_cards_i915 ; then
		if (use i915_classic_driver) ; then
			dri_enable i915
		else
			gallium_enable i915
		fi
	fi

	if use video_cards_i965 ; then
		dri_enable i965
		use vulkan && vulkan_enable intel
	fi

	if use video_cards_i965 || use video_cards_i915 ; then
		tool_enable intel
	fi


	# Nouveau (nvidia) cards
	if use video_cards_nouveau; then
		if (use nouveau_classic_driver) ; then
			dri_enable nouveau
		else
			gallium_enable nouveau
			gallium_enable video_cards_tegra tegra
		fi
		tool_enable nouveau
	fi

	# ATI/AMD cards
	# Older Radeon cards
	dri_enable video_cards_r100 r100
	dri_enable video_cards_r200 r200
	gallium_enable video_cards_r300 r300
	gallium_enable video_cards_r600 r600
	# Newer Radeon cards (Southern Islands/GCN1.0+)
	if use video_cards_radeonsi ; then
		gallium_enable video_cards_radeonsi radeonsi
		use vulkan && vulkan_enable amd
	fi


	# vc4/pl111 drivers
	gallium_enable video_cards_vc4 vc4
	gallium_enable video_cards_pl111 pl111

	# etnaviv/imx drivers
	gallium_enable video_cards_vivante etnaviv
	gallium_enable video_cards_imx imx

	# freedreno drivers
	gallium_enable video_cards_freedreno freedreno
	tool_enable video_cards_freedreno freedreno

	# SVGA drivers (needed for vmware)
	if use video_cards_vmware ; then
		gallium_enable svga
	fi


	# Enable the various platforms
	platform_enable X x11
	platform_enable drm drm
	platform_enable wayland wayland
	platform_enable surfaceless surfaceless
	platform_enable android android
	platform_enable haiku haiku

	# Enable supported arches for OpenSWR based on cpu_flags_x86_*
	for swr_arch in ${ALL_SWR_ARCHES} ; do
		case "${swr_arch}" in
			knl) swr_cpuflag=avx512er ;;
			skx) swr_cpuflag=avx512bw ;;
			*) swr_cpuflag="${swr_arch}"

		esac
		if use cpu_flags_x86_${swr_cpuflag} ; then
			SWR_ARCHES+="${SWR_ARCHES:+,}${swr_arch}"
		fi
	done

	# Setup for alternate install paths
	if use alternate-path ; then
		local my_prefix="${EPREFIX}/usr/$(get_libdir)/${P}"
		local my_libdir="lib"
	else
		local my_prefix="${EPREFIX}/usr"
		local my_libdir="$(get_libdir)"
	fi

	local emesonargs=(
		--prefix="${my_prefix}"
		--libdir="${my_libdir}"

		-Dplatforms=${PLATFORMS}

		-Ddri3=$(usex dri3 true false)

		-Ddri-drivers=${DRI_DRIVERS}
		#-Ddri-drivers-path=${my_prefix}/dri
		#-Ddri-search-path=

		-Dgallium-drivers=${GALLIUM_DRIVERS}
		-Dgallium-extra-hud=$(usex extra-hud true false)

		-Dgallium-vdpau=$(usex vdpau true false)
		#$(use vdpau && printf -- "-Dvdpau-libs-path=${my_prefix}/vdpau")

		-Dgallium-xvmc=$(usex xvmc true false)
		#-Dxvmc-libs-path=

		-Dgallium-omx=$(usex openmax bellagio disabled)
		#$(use openmax && printf -- "-Domx-libs-path=${my_prefix}/omx")

		-Dgallium-va=$(usex vaapi true false)
		$(use vaapi && printf -- "-Dva-libs-path=${my_libdir}/va/drivers")

		-Dgallium-xa=$(usex xa true false)

		-Dgallium-nine=$(usex d3d9 true false)
		#$(use d3d9 && printf -- "-Dd3d-drivers-path=${my_prefix}/d3d")

		-Dgallium-opencl=$(usex opencl $(usex ocl-icd icd standalone) disabled)

		-Dvulkan-drivers=${VULKAN_DRIVERS}
		#$(use vulkan && printf -- "-Dvulkan-icd-dir=${my_prefix}/vulkan")

		-Dshader-cache=$(usex shader-cache true false)

		-Dshared-glapi=$(usex opengl true false)
		-Dgles1=$(usex gles1 true false)
		-Dgles2=$(usex gles2 true false)
		-Dopengl=$(usex opengl true false)

		-Dgbm=$(usex gbm true false)
		-Dglx=$(usex glx dri disabled)
		-Degl=$(usex egl true false)

		-Dglvnd=$(usex glvnd true false)

		-Dasm=$(if [[ ${ABI} == x86* ]] ; then echo "false" ; else echo "true"; fi)
		-Dglx-read-only-text=$(if [[ ${ABI} == x86 ]] && use pax_kernel ; then echo "true" ; else echo "false"; fi)
		-Dllvm=$(usex llvm true false)
		-Dvalgrind=$(usex valgrind auto false)
		-Dlibunwind=$(usex unwind true false)
		-Dlmsensors=$(usex sensors true false)
		-Dbuild-tests=$(usex test true false)

		-Dselinux=$(usex selinux true false)

		-Dosmesa=$(usex osmesa $(usex swrast_classic_driver classic gallium) none)
		-Dosmesa-bits=8

		-Dswr-arches=${SWR_ARCHES}
		-Dtools=${TOOLS}
		#-Dpower8=
		-Dxlib-lease=$(usex xlib_lease true false)
	)

	if use llvm ; then
		export LLVM_CONFIG="$(llvm-config --prefix)/bin/$(get_abi_CHOST)-llvm-config"
	fi

	use userland_GNU || export INDENT=cat


	# We can't actually use meson_src_configure because it hard-codes the buildtype, prefix, libdir, etc.
	# meson_src_configure

	# Common args -- This is where we need to override:
	local mesonargs=(
			--buildtype $(usex debug debugoptimized release)
			-Db_ndebug=if-release
			--libdir "${my_libdir}"
			--localstatedir "${EPREFIX}/var/lib"
			--sharedstatedir "${EPREFIX}/usr/share/${P}"
			--prefix "${my_prefix}"
			--wrap-mode nodownload
			)

	
	#if tc-is-cross-compiler || [[ ${ABI} != ${DEFAULT_ABI-${ABI}} ]]; then
			_meson_create_cross_file || die "unable to write meson cross file"
			meson_cross=( --cross-file "${T}/meson.${CHOST}.${ABI}" )
	#fi

	# https://bugs.gentoo.org/625396
	python_export_utf8_locale

	# Append additional arguments from ebuild
	mesonargs+=("${emesonargs[@]}")

	set -- meson "${EMESON_SOURCE:-${S}}" "${BUILD_DIR}" "${meson_cross[@]}" "${mesonargs[@]}"
	echo "$@"
	tc-env_build "$@" || die
}

multilib_src_compile() {
	eninja -C "${BUILD_DIR}"

}


multilib_src_install() {
	meson_src_install DESTDIR="${D}"

	# Cleanup files we shouldn't be installing when using libglvnd
	if use glvnd ; then 
		find "${ED}/usr/$(get_libdir)/" -name 'libGLESv[12]*.so*' -delete
	#	find "${ED}/usr/$(get_libdir)/pkgconfig/" -name 'gl.pc' -delete
	fi
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -delete
	einstalldocs

	# Install config file for eselect mesa
	#insinto /usr/share/mesa
	#newins "${FILESDIR}/eselect-mesa.conf.9.2" eselect-mesa.conf
}

multilib_src_test() {
	if use llvm; then
		local llvm_tests='lp_test_arit lp_test_arit lp_test_blend lp_test_blend lp_test_conv lp_test_conv lp_test_format lp_test_format lp_test_printf lp_test_printf'
		pushd src/gallium/drivers/llvmpipe >/dev/null || die
		emake ${llvm_tests}
		pax-mark m ${llvm_tests}
		popd >/dev/null || die
	fi
	emake check
}

pkg_postinst() {

	if use openmax; then
		echo "XDG_DATA_DIRS=\"${EPREFIX}/usr/share/${P}/xdg\"" > "${T}/99mesaxdgomx"
		doenvd "${T}"/99mesaxdgomx
		keepdir /usr/share/mesa/xdg
	fi

	# Switch to the xorg implementation.
	#echo
	#eselect opengl set --use-old ${OPENGL_DIR}


	# Switch to mesa opencl
	if use opencl; then
		einfo "Make sure you have the ocl-icd OpenCL dispatcher enabled:"
		einfo "    # eselect opencl set --use-old ocl-icd"
	fi

	# run omxregister-bellagio to make the OpenMAX drivers known system-wide
	if use openmax; then
		ebegin "Registering OpenMAX drivers"
		BELLAGIO_SEARCH_PATH="${EPREFIX}/usr/$(get_libdir)/${P}/libomxil-bellagio0" \
			OMX_BELLAGIO_REGISTRY=${EPREFIX}/usr/share/${P}/xdg/.omxregister \
			omxregister-bellagio
		eend $?
	fi
}

pkg_prerm() {
	if use openmax; then
		rm "${EPREFIX}"/usr/share/${P}/xdg/.omxregister
	fi
}


# $1 - name of list to add item to
# $2... - list of items to add

_list_add_item() {
	local list_name="$1"
	shift
	while [ $# -gt 0 ] ; do
		local list_val="${!list_name}"
		if ! (IFS=',' has "$1" "${list_val}" ) ; then
			printf -v ${list_name} '%s%s' "${list_val:+${list_val},}" "$1"
		fi
		shift
	done
}

# $1 - name of list to operate on
# $2 - item to enable (if no following args)
# $2 - USE flag to check (if more args follow)
# $3... - list of items to enable if USE flag enabled

_list_enable() {
	local i list
	list="$1"; shift
	case $# in
		0) return 0 ;;
		1) _list_add_item "$list" "$1" ;;
		*) if use "$1" ; then shift ; for i in "$@"; do _list_add_item "$list" "$i" ; done ; fi ;;
	esac
}

dri_enable() {
	_list_enable "DRI_DRIVERS" "$@"
}

gallium_enable() {
	_list_enable "GALLIUM_DRIVERS" "$@"
}

vulkan_enable() {
	_list_enable "VULKAN_DRIVERS" "$@"
}

platform_enable() {
	_list_enable "PLATFORMS" "$@"
}

tool_enable() {
	_list_enable "TOOLS" "$@"
}
