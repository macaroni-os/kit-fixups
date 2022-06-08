# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_EXTENSIONS=(ext/stringio/extconf.rb)
RUBY_FAKEGEM_GEMSPEC="stringio.gemspec"

inherit ruby-fakegem

DESCRIPTION="Pseudo IO class from/to String."
HOMEPAGE="https://github.com/ruby/stringio"
SRC_URI="https://github.com/ruby/stringio/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
KEYWORDS="*"
SLOT="0"
IUSE="test"

all_ruby_prepare() {
	sed -e "/s.version =/ s/source_version/'${PV}'/" \
		-e 's/__dir__/"."/' \
		-i ${RUBY_FAKEGEM_GEMSPEC} || die
}

each_ruby_test() {
	${RUBY} -Ilib:.:test -e 'Dir["test/test_*.rb"].each{|f| require f}' || die
}
