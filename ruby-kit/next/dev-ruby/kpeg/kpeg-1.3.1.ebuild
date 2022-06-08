# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

inherit ruby-fakegem

DESCRIPTION="A simple PEG library for Ruby"
HOMEPAGE="https://github.com/evanphx/kpeg"

LICENSE="MIT"
SLOT="1"
KEYWORDS="*"
IUSE="test"

PATCHES=( "${FILESDIR}/kpeg-1.1.0-utf8.patch" )

ruby_add_bdepend "test? ( dev-ruby/minitest:5 )"

each_ruby_test() {
	${RUBY} -Ilib:test:. -e 'gem "minitest", "~>5.0"; Dir["test/test_*.rb"].each{|f| require f}' || die
}
