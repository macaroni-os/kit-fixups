# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

RUBY_FAKEGEM_EXTRADOC="README.md"

RUBY_FAKEGEM_BINWRAP=""

RUBY_FAKEGEM_GEMSPEC="power_assert.gemspec"

inherit ruby-fakegem

DESCRIPTION="Shows each value of variables and method calls in the expression"
HOMEPAGE="https://github.com/ruby/power_assert"
SRC_URI="https://github.com/ruby/power_assert/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="|| ( Ruby BSD-2 )"

KEYWORDS="*"

SLOT="0"
IUSE=""

ruby_add_bdepend "test? ( dev-ruby/test-unit )"

all_ruby_prepare() {
	sed -i -e '/bundler/I s:^:#:' Rakefile test/test_helper.rb || die
	sed -i -e '1igem "test-unit"' \
		-e '/byebug/ s:^:#:' test/test_helper.rb || die

	# Avoid git dependency
	sed -i -e 's/git ls-files -z/find . -print0/' ${RUBY_FAKEGEM_GEMSPEC} || die

	# Avoid circular dependency on byebug when bootstrapping ruby
	sed -i -e '/byebug/ s:^:#:' -e '/test_core_ext_helper/ s:^:#:' test/test_helper.rb || die
	rm test/test_core_ext_helper.rb test/trace_test.rb || die

	# Avoid circular dependency on pry when bootstrapping ruby
	sed -i -e '/pry/ s:^:#:' -e '/test_colorized_pp/,/^    end/ s:^:#:' test/block_test.rb || die
}