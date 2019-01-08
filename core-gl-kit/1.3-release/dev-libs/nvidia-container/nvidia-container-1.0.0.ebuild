# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="NVIDIA container runtime library"
HOMEPAGE="https://github.com/NVIDIA/libnvidia-container"
SRC_URI="https://github.com/NVIDIA/libnvidia-container/releases/download/v1.0.0/libnvidia-container_1.0.0_x86_64.tar.xz -> ${P}.tar.xz"
LICENSE="NVIDIA CORPORATION"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	net-libs/libtirpc
	sys-libs/libcap
	sys-libs/libseccomp
"

S=${WORKDIR}/libnvidia-container_${PV}

QA_PRESTRIPPED="/usr/bin/nvidia-container-cli"
QA_PRESTRIPPED="usr/lib/libnvidia-container.so*"

src_install() {
	insinto /usr/include
	doins usr/local/include/nvc.h
	dobin usr/local/bin/nvidia-container-cli
	insinto /usr/share/pkgconfig
	doins usr/local/lib/pkgconfig/libnvidia-container.pc
	dolib.a usr/local/lib/libnvidia-container.a
	dolib.so usr/local/lib/libnvidia-container.so.${PV}
	dosym /usr/lib/libnvidia-container.so.${PV} /usr/lib/libnvidia-container.so.1
	dosym /usr/lib/libnvidia-container.so.${PV} /usr/lib/libnvidia-container.so
}

