# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit java-pkg-2

MY_PN=apache-${PN%%-bin}
MY_PV=${PV/_alpha/-alpha-}
MY_P="${MY_PN}-${MY_PV}"
MY_MV="${PV%%.*}"

DESCRIPTION="Project Management and Comprehension Tool for Java"
SRC_URI="https://dlcdn.apache.org/ant/binaries/${MY_P}-bin.tar.gz"
HOMEPAGE="https://ant.apache.org/"

LICENSE="Apache-2.0"
SLOT="1.10"
KEYWORDS="amd64 x86"

DEPEND="
        >=virtual/jdk-1.8
        app-eselect/eselect-java
        dev-java/java-config"

RDEPEND="
        >=virtual/jre-1.8"

S="${WORKDIR}/${MY_P}"

ANT="${PN}-${SLOT}"
ANT_SHARE="/usr/share/${ANT}"


src_install() {
        dodir "${ANT_SHARE}"

        cp -Rp bin etc lib manual "${ED}/${ANT_SHARE}" || die "failed to copy"

        java-pkg_regjar "${ED}/${ANT_SHARE}"/etc/*.jar
        java-pkg_regjar "${ED}/${ANT_SHARE}"/lib/*.jar

        dodoc NOTICE README WHATSNEW INSTALL CONTRIBUTORS KEYS LICENSE

        dodir /usr/bin
        dosym "${ANT_SHARE}/bin/ant" /usr/bin/ant-${SLOT}
        dosym /usr/bin/ant-${SLOT} /usr/bin/ant
}
