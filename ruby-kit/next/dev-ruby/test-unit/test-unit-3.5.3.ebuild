# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

RUBY_FAKEGEM_EXTRADOC="README.md doc-install/text/*.md"

RUBY_FAKEGEM_GEMSPEC="test-unit.gemspec"

inherit ruby-fakegem

DESCRIPTION="An xUnit family unit testing framework for Ruby"
HOMEPAGE="https://rubygems.org/gems/test-unit"
SRC_URI="https://github.com/test-unit/test-unit/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( Ruby GPL-2 ) PSF-2"
SLOT="2"
KEYWORDS="*"
IUSE="doc test"

ruby_add_rdepend "dev-ruby/power_assert"

all_ruby_prepare() {
	mv doc doc-install || die "moving doc directory out of the way failed"
}

each_ruby_test() {
	${RUBY} test/run-test.rb || die "testsuite failed"
}

all_ruby_install() {
	all_fakegem_install

	newbin "${FILESDIR}"/testrb-3 testrb-2
}
