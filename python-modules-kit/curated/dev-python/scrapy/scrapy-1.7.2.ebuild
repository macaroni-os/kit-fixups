# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit distutils-r1

DESCRIPTION="A high-level Web Crawling and Web Scraping framework"
HOMEPAGE="https://scrapy.org/"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
SRC_URI="https://github.com/scrapy/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"


KEYWORDS="~amd64 ~x86"
LICENSE="BSD-2"
SLOT="0"
IUSE="boto doc ibl -test ssl"

RDEPEND="
	>=dev-python/six-1.5.2[${PYTHON_USEDEP}]
	dev-libs/libxml2[python,${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	>=dev-python/parsel-1.5[${PYTHON_USEDEP}]
	>=dev-python/lxml-3.4[${PYTHON_USEDEP}]
	>=dev-python/pydispatcher-2.0.5[${PYTHON_USEDEP}]
	ibl? ( dev-python/numpy[${PYTHON_USEDEP}] )
	ssl? (
			>=dev-python/pyopenssl-0.14[${PYTHON_USEDEP}]
			dev-python/cryptography[${PYTHON_USEDEP}]
	)
	boto? ( dev-python/boto3[${PYTHON_USEDEP}] )
	>=dev-python/twisted-17.9[${PYTHON_USEDEP}]
	>=dev-python/w3lib-1.17.0[${PYTHON_USEDEP}]
	>=dev-python/queuelib-1.1.1[${PYTHON_USEDEP}]
	>=dev-python/cssselect-0.9[${PYTHON_USEDEP}]
	>=dev-python/six-1.5.2[${PYTHON_USEDEP}]
	dev-python/service_identity[${PYTHON_USEDEP}]
	$(python_gen_cond_dep 'dev-python/functools32[${PYTHON_USEDEP}]' python2_7)
	"

DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
		=net-proxy/mitmproxy-0.10.1[${PYTHON_USEDEP}]
		=dev-python/netlib-0.10.1[${PYTHON_USEDEP}]
		dev-python/jmespath[${PYTHON_USEDEP}]
		dev-python/testfixtures[${PYTHON_USEDEP}]
		net-ftp/vsftpd
	)
"

# pytest-twisted listed as a test dep but not in portage.
# Testsuite currently survives without it, so appears optional

REQUIRED_USE="test? ( ssl boto )" 

python_prepare_all() {
	sed -e "s/PyDispatcher/PyPyDispatcher/g" -i setup.py || die

	# https://github.com/scrapy/scrapy/issues/1464
	# Disable failing tests known to pass according to upstream
	# Awaiting a fix planned by package owner.
	sed -e 's:test_https_connect_tunnel:_&:' \
			-e 's:test_https_connect_tunnel_error:_&:' \
			-e 's:test_https_tunnel_auth_error:_&:' \
			-e 's:test_https_tunnel_without_leak_proxy_authorization_header:_&:' \
			-i tests/test_proxy_connect.py || die
	
	distutils-r1_python_prepare_all
}

python_compile_all() {
	if use doc; then
			PYTHONPATH="${S}" emake -C docs html || die "emake html failed"
	fi
}

python_test() {
	py.test ${PN} tests || die "tests failed"
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/build/html/. )
	distutils-r1_python_install_all
}
