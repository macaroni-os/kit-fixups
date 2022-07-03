# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Java Runtime Environment (JRE)"
SLOT="${PV}"
KEYWORDS="*"

RDEPEND="|| (
		virtual/jdk:${SLOT}
		dev-java/oracle-jre-bin:${SLOT}[gentoo-vm(+)]
		dev-java/openjdk-jre-bin:${SLOT}[gentoo-vm(+)]
		dev-java/openjdk-jre:${SLOT}[gentoo-vm(+)]
	)"
