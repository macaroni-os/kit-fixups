# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="History.rdoc README.rdoc"

inherit ruby-fakegem

DESCRIPTION="minitest/unit is a small and fast replacement for ruby's huge and slow test/unit"
HOMEPAGE="https://github.com/seattlerb/minitest"

LICENSE="MIT"
SLOT="5"
KEYWORDS="*"
IUSE="doc test"

each_ruby_test() {
	MT_NO_PLUGINS=true ${RUBY} -Ilib:test:. -e "Dir['**/test_*.rb'].each{|f| require f}" || die "Tests failed"
}
