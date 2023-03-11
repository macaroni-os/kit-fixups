# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Java Development Kit (JDK)"
SLOT="${PV}"
KEYWORDS="*"
IUSE="headless-awt"

RDEPEND="|| (
		dev-java/oracle-jdk-bin:${SLOT}[gentoo-vm(+),headless-awt=]
		dev-java/openjdk-bin:${SLOT}[gentoo-vm(+),headless-awt=]
		dev-java/openjdk:${SLOT}[gentoo-vm(+),headless-awt=]
	)"
