# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Virtual for Java Runtime Environment (JRE)"
SLOT="1.8"
KEYWORDS="*"

RDEPEND="|| (
		virtual/jdk:1.8
		dev-java/oracle-jre-bin:1.8
	)"
