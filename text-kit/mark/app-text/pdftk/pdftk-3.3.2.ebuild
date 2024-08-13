# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit java-pkg-2

DESCRIPTION="Java version of pdftk"
HOMEPAGE="https://gitlab.com/pdftk-java/pdftk"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.com/pdftk-java/pdftk/"
else
	SRC_URI="https://gitlab.com/pdftk-java/pdftk/-/archive/v${PV}/pdftk-v${PV}.tar.bz2"
	KEYWORDS="amd64 ~x86"
	S="${WORKDIR}/pdftk-v${PV}"
fi

LICENSE="GPL-2"
SLOT="0"

JAVA_PKG_STRICT="yes"
RESTRICT="network-sandbox"

CDEPEND="
    dev-java/maven-bin"

DEPEND="
	${CDEPEND}
	>=virtual/jdk-11
	dev-java/javatoolkit"

RDEPEND="
	>=virtual/jdk-11"


src_compile() {
    /usr/bin/mvn clean package -DskipTests
}

src_install() {
	java-pkg_newjar "target/pdftk-java-${PV}.jar"
	java-pkg_dolauncher ${PN} --main com.gitlab.pdftk_java.pdftk
	doman "${PN}.1"
}
