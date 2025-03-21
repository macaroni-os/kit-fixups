# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake

DESCRIPTION="OpenMP runtime library for LLVM/clang compiler"
HOMEPAGE="https://openmp.llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions || ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="*"
IUSE="cuda debug hwloc offload ompt llvm_targets_AMDGPU llvm_targets_NVPTX abi_x86_64"
REQUIRED_USE="cuda? ( llvm_targets_NVPTX )
offload? ( cuda? ( abi_x86_64 ) )
"
DEPEND="${RDEPEND}
	
"
BDEPEND="dev-lang/perl
	offload? (
	  llvm_targets_AMDGPU? ( sys-devel/clang )
	  llvm_targets_NVPTX? ( sys-devel/clang )
	  virtual/pkgconfig
	)
	
"
RDEPEND="hwloc? ( sys-apps/hwloc:0= )
	offload? (
	  virtual/libelf
	  dev-libs/libffi
	  ~sys-devel/llvm-16.0.6
	)
	
"
S="${WORKDIR}/llvm-src/openmp"
post_src_unpack() {
	mv llvm-project-* llvm-src
}
src_configure() {
	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	local libdir="$(get_libdir)"
	local mycmakeargs=(
	  -DOPENMP_LIBDIR_SUFFIX="${libdir#lib}"
	  -DLIBOMP_USE_HWLOC=$(usex hwloc)
	  -DLIBOMP_OMPT_SUPPORT=$(usex ompt)
	  -DOPENMP_ENABLE_LIBOMPTARGET=$(usex offload)
	  # do not install libgomp.so & libiomp5.so aliases
	  -DLIBOMP_INSTALL_ALIASES=OFF
	  # disable unnecessary hack copying stuff back to srcdir
	  -DLIBOMP_COPY_EXPORTS=OFF
	  # prevent trying to access the GPU
	  -DLIBOMPTARGET_AMDGPU_ARCH=LIBOMPTARGET_AMDGPU_ARCH-NOTFOUND
	  -DOPENMP_LLVM_LIT_EXECUTABLE="${EPREFIX}/usr/bin/lit"
	)
	use offload && mycmakeargs+=(
	  -DLIBOMPTARGET_BUILD_AMDGPU_PLUGIN=$(usex llvm_targets_AMDGPU)
	  -DLIBOMPTARGET_BUILD_CUDA_PLUGIN=$(usex llvm_targets_NVPTX)
	)
	addpredict /dev/nvidiactl
	cmake_src_configure
}


# vim: filetype=ebuild
