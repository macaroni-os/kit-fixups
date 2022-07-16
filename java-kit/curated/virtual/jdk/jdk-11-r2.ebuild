# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Java Development Kit (JDK)"
SLOT="11"
KEYWORDS="*"
IUSE="headless-awt"

RDEPEND="|| (
		dev-java/openjdk-bin:11[gentoo-vm(+),headless-awt=]
		dev-java/openjdk:11[gentoo-vm(+),headless-awt=]
	)"
