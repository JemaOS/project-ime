# Copyright (c) 2024 Jema Technology and the openJema Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright 2010-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=(python{3_6,3_7,3_8,3_9})

inherit cmake python-any-r1

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/BYVoid/OpenCC"
fi

DESCRIPTION="Library for conversion between Traditional and Simplified Chinese characters"
HOMEPAGE="https://github.com/BYVoid/OpenCC"
if [[ "${PV}" == "9999" ]]; then
	SRC_URI=""
else
	SRC_URI="https://github.com/BYVoid/OpenCC/archive/ver.${PV}.tar.gz -> ${P}.tar.gz"
fi

# OpenCC: Apache-2.0
# deps/darts-clone: BSD-2
# deps/gtest-1.7.0: BSD
# deps/rapidjson-0.11: MIT
# deps/tclap-1.2.1: MIT
LICENSE="Apache-2.0 BSD-2 MIT test? ( BSD )"
SLOT="0/2"
KEYWORDS="amd64 arm64 ~hppa ppc ppc64 sparc x86 arm"
IUSE="doc test"
RESTRICT="!test? ( test ) arm? ( binchecks )"

BDEPEND="${PYTHON_DEPS}
	doc? ( app-doc/doxygen )"
DEPEND=""
RDEPEND=""

if [[ "${PV}" != "9999" ]]; then
	S="${WORKDIR}/OpenCC-ver.${PV}"
fi

PATCHES=(
	"${FILESDIR}/${PN}-1.0.5-fix_dict_path.patch"
	"${FILESDIR}/${PN}-test.patch"
	"${FILESDIR}/${PN}-stop-copy.patch"
)

DOCS=(AUTHORS NEWS.md README.md)

src_prepare() {

        cros_enable_cxx_exceptions
	cmake_src_prepare

	sed -e "s:\${DIR_SHARE_OPENCC}/doc:share/doc/${PF}:" -i doc/CMakeLists.txt || die
	

	if [[ "${ARCH}" == "arm" ]]; then
	   SED_OPTION="s/\${QEMU_RUN_COMMAND}/qemu-arm -L \/usr\/${CHOST}/g"
	   sed -i "${SED_OPTION}" data/CMakeLists.txt
	fi

	if [[ "${ARCH}" == "arm64" ]]; then
           SED_OPTION="s/\${QEMU_RUN_COMMAND}/qemu-aarch64 -L \/usr\/${CHOST}/g"
           sed -i "${SED_OPTION}" data/CMakeLists.txt
	fi
	
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DBUILD_SHARED_LIBS=ON
		-DENABLE_GTEST=$(usex test ON OFF)
	)

	cmake_src_configure
}
