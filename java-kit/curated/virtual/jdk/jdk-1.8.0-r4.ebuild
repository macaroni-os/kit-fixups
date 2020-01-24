# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Virtual for Java Development Kit (JDK)"
SLOT="1.8"
KEYWORDS="*"

RDEPEND="|| (
		dev-java/oracle-jdk-bin:1.8
		dev-java/icedtea-bin:8
		dev-java/icedtea:8
		dev-java/openjdk-bin:8[gentoo-vm(+)]
		dev-java/openjdk:8[gentoo-vm(+)]
	)"
