# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-build

DESCRIPTION="Virtual for Rust language compiler"

LICENSE=""
SLOT="0"
KEYWORDS="*"

BDEPEND=""
RDEPEND="|| ( ~dev-lang/rust-bin-1.66.1[${MULTILIB_USEDEP}] ~dev-lang/rust-1.66.1[${MULTILIB_USEDEP}] )"
