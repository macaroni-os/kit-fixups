# Copyright 1999-2018 Gentoo Foundation

EAPI=6

DESCRIPTION="Virtual for OpenCL implementations"
SLOT="0"
KEYWORDS="amd64 x86"
CARDS=( amdgpu i965 nvidia )
IUSE="${CARDS[@]/#/video_cards_}"

# amdgpu-pro-opencl and intel-ocl-sdk are amd64-only
RDEPEND="app-eselect/eselect-opencl
	|| (
		>=media-libs/mesa-9.1.6[opencl]
		amd64? (
			video_cards_amdgpu? ( dev-libs/amdgpu-pro-opencl )
			dev-util/intel-ocl-sdk
		)
		video_cards_i965? ( dev-libs/beignet )
		video_cards_nvidia? ( >=x11-drivers/nvidia-drivers-290.10-r2[opencl] )
	)"
