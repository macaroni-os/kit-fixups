# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rpm
DESCRIPTION="A modified version of runc adding a custom pre-start hook to all containers"
HOMEPAGE="https://github.com/NVIDIA/nvidia-container-runtime"
SRC_URI="https://nvidia.github.io/nvidia-container-runtime/centos7/x86_64/${PN}-2.0.0-1.docker18.03.0.x86_64.rpm https://github.com/NVIDIA/nvidia-container-runtime/releases/download/v1.4.0-1/nvidia-container-runtime-hook.amd64"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-libs/nvidia-container
	sys-libs/libseccomp"
S=${WORKDIR}

src_unpack() {
	rpm_src_unpack
}

src_install() {
	newbin usr/bin/${PN} ${PN}

	exeinto /usr/bin
	newexe ${DISTDIR}/nvidia-container-runtime-hook.amd64 nvidia-container-runtime-hook
}
