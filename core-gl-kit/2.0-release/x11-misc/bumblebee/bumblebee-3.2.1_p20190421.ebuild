# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools multilib readme.gentoo-r1 user

COMMIT="7aa457fe7b4fffc3b175ad36fdae00d7777065dc"
SRC_URI="https://github.com/Bumblebee-Project/Bumblebee/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/Bumblebee-${COMMIT}"

DESCRIPTION="Service providing elegant and stable means of managing Optimus graphics chipsets"
HOMEPAGE="https://bumblebee-project.org https://github.com/Bumblebee-Project/Bumblebee"

SLOT="0"
LICENSE="GPL-3"

IUSE="+bbswitch video_cards_nouveau video_cards_nvidia"

COMMON_DEPEND="
	dev-libs/glib:2
	dev-libs/libbsd
	sys-apps/kmod
	x11-libs/libX11
"

RDEPEND="${COMMON_DEPEND}
	virtual/opengl
	x11-base/xorg-drivers[video_cards_nvidia?,video_cards_nouveau?]
	bbswitch? ( sys-power/bbswitch )
"

DEPEND="${COMMON_DEPEND}
	sys-apps/help2man
	virtual/pkgconfig
"

PDEPEND="
	|| (
		x11-misc/primus
		x11-misc/virtualgl
	)
"

REQUIRED_USE="|| ( video_cards_nouveau video_cards_nvidia )"

pkg_setup() {
	enewgroup bumblebee
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	if use video_cards_nvidia ; then
		# Get paths to GL libs for all ABIs
		local i nvlib=""
		for i in  $(get_all_libdirs) ; do
			nvlib="${nvlib}:/usr/${i}"
		done

		local nvpref="/usr/$(get_libdir)/nvidia"
		local xorgpref="/usr/$(get_libdir)/xorg/modules"
		ECONF_PARAMS="CONF_DRIVER=nvidia CONF_DRIVER_MODULE_NVIDIA=nvidia-drm \
			CONF_LDPATH_NVIDIA=${nvlib#:} \
			CONF_MODPATH_NVIDIA=${nvpref},${nvpref}/opengl/nvidia/extensions,${xorgpref}/drivers,${xorgpref}"
	fi

	econf \
		${ECONF_PARAMS}
}

src_install() {
	default

	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newenvd "${FILESDIR}"/${PN}.envd 99${PN}

	local DOC_CONTENTS="In order to use Bumblebee, add your user to 'bumblebee' group.
		You may need to setup your /etc/bumblebee/bumblebee.conf"
	readme.gentoo_create_doc
}

pkg_postinst() {
	if ! has_version x11-drivers/xf86-video-intel[tools]; then
		elog "If you have issues with external monitors not working, the video output port"
		elog "may be wired to the discrete nVidia chip. In such case, you need to install"
		elog "x11-drivers/xf86-video-intel with the 'tools' USE flag enabled in order"
		elog "to have access to the 'intel-virtual-output' command."
		elog ""
	fi
}
