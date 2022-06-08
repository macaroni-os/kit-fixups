# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

RUBY_FAKEGEM_EXTRADOC="NEWS.md README.md"

inherit ruby-fakegem

DESCRIPTION="Family of libraries that support various formats of XML feeds"
HOMEPAGE="https://github.com/ruby/rss"

LICENSE="BSD-2"
KEYWORDS="*"
SLOT="0"
IUSE="test"

ruby_add_rdepend "dev-ruby/rexml"

ruby_add_bdepend "test? ( dev-ruby/test-unit )"

all_ruby_prepare() {
	sed -i -e '/bundler/,/^helper.install/ s:^:#:' Rakefile || die
}
