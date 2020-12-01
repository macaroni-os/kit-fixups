# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_COMMIT="35139deedbd5182953cf1caa23835da59ca3d7cd"
README_GENTOO_SUFFIX="-r1"

inherit java-pkg-2 user

DESCRIPTION="The official server for the sandbox video game Minecraft"
HOMEPAGE="https://www.minecraft.net/"
SRC_URI="https://launcher.mojang.com/v1/objects/${EGIT_COMMIT}/server.jar -> ${P}.jar"

LICENSE="Mojang"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	app-misc/dtach
	|| (
		>=virtual/jre-1.8
		>=virtual/jdk-1.8
	)
"

RESTRICT="bindist mirror strip"

S="${WORKDIR}"

pkg_setup() {
	enewgroup minecraft
	enewuser minecraft -1 -1 /var/lib/minecraft-server minecraft
}

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}" || die
}

src_compile() {
	:;
}

src_install() {
	java-pkg_newjar minecraft-server-${PV}.jar minecraft-server.jar
	java-pkg_dolauncher minecraft-server --jar minecraft-server.jar --java_args "\${JAVA_OPTS}"

	newinitd "${FILESDIR}"/minecraft-server.initd-r4 minecraft-server
	newconfd "${FILESDIR}"/minecraft-server.confd-r1 minecraft-server
}

pkg_postinst() {
	elog "This package provides an init script and a conf file."
	elog "Create a symlink of the init script and a copy of the conf file."
	elog "Edit the conf file according to how you want to set the server up."
	elog "You can do this for every server you want to set up."
	elog "e.g. you want to set up a world called funtoo you would do:"
	elog "cd /etc/init.d"
	elog "ln -s minecraft-server mincraft-server.funtoo"
	elog "cd /etc/conf.d"
	elog "cp minecraft-server minecraft-server.funtoo"
	elog "edit your newly created minecraft-server.funtoo"
	elog "To interact with the console of the corresponding world,"
	elog "you can use the command attach like so:"
	elog "rc-service minecraft-server.funtoo attach"
}
