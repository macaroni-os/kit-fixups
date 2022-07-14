# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Java Runtime Environment (JRE)"
SLOT="11"
KEYWORDS="*"

RDEPEND="|| (
		virtual/jdk:11
		dev-java/openjdk-jre-bin:11[gentoo-vm(+)]
	)"
