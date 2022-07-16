# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Virtual for Java Development Kit (JDK)"
SLOT="1.8"
KEYWORDS="*"
IUSE="headless-awt"

RDEPEND="|| (
		dev-java/icedtea-bin:8[headless-awt=]
		dev-java/openjdk-bin:8[gentoo-vm(+),headless-awt=]
		dev-java/icedtea:8[headless-awt=]
		dev-java/openjdk:8[gentoo-vm(+),headless-awt=]
	)"
