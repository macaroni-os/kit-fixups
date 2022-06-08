# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby26 ruby27 ruby30 ruby31"

RUBY_FAKEGEM_RECIPE_DOC=""
RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.md"

inherit ruby-fakegem

DESCRIPTION="'did you mean?'experience in Ruby"
HOMEPAGE="https://github.com/yuki24/did_you_mean"

LICENSE="MIT"
SLOT="2.6"
KEYWORDS="*"
IUSE=""

ruby_add_bdepend "test? ( dev-ruby/minitest:5 )"

all_ruby_prepare() {
	sed -i -e '/bundler/ s:^:#:' Rakefile || die
}
