async def generate(hub, **pkginfo):
	# /usr/src/linux/tools/usb/usbip # cat configure.ac | grep AC_INIT
	# AC_INIT([usbip-utils], [2.0], [linux-usb@vger.kernel.org])
	usbiputils_version = "2.0"
	kernel_version = "6.1.106"

	artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-{kernel_version}.tar.xz"
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		kernel_version=kernel_version,
		version=usbiputils_version + "_p" + kernel_version.replace(".", ""),
		artifacts=[artifact]
	)
	ebuild.push()

