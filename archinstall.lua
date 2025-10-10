local specs = {
    rootMountPoint = "/mnt",
    rootPart = "/dev/nvme0n1p8",
	rootLabel = "ARCH",
    esp = nil,
	espMountPoint = "/mnt/boot",
	espLabel = "ESP",
	parallelDownloads = 30,
	packages = {"base", "linux", "linux-firmware"},
	bootLoader = "grub",
	user = "arch",
	hostname = "thebasement",
	timezone = "Asia/Kolkata",
	locale = "en_US.UTF-8 UTF-8",
	lang = "en_US.UTF-8",
}

local formatRoot = string.format("mkfs.ext4 -L %s %s", specs.rootLabel, specs.rootPart)
local formatESP = string.format("mkfs.fat -F 32 -L %s %s", specs.espLabel, specs.esp)
local mountRoot = string.format("mount %s %s", specs.rootPart, specs.rootMountPoint)
local mountESP = string.format("mount --mkdir %s %s", specs.esp, specs.espMountPoint)
local enableParallelDownload = string.format("sed -i 's/^.*ParallelDownload.*$/ParallelDownloads = %s/' /etc/pacman.conf", specs.parallelDownloads)
local pactstrap = string.format("pactstrap -P -K %s %s", specs.rootMountPoint, table.concat(specs.packages, " "))
local genfstab = string.format("genfstab %s > %s/etc/fstab", specs.rootMountPoint, specs.rootMountPoint)
local chroot = string.format("arch-chroot %s", specs.rootMountPoint)
local timezone = string.format("%s ln -sf /usr/share/zoneinfo/%s /etc/localtime", chroot, specs.timezone)
local hwclock = "%s hwclock --systohc"
local locale = string.format("%s echo %s >> /etc/locale.gen", chroot, specs.locale)
local localeGen = "%s locale-gen"
local lang = string.format("%s echo 'LANG = %s' > /etc/locale.conf", chroot, specs.lang)
local hostname = string.format("%s echo %s > /etc/hostname", chroot, specs.hostname)
local passwd = string.format("%s passwd", chroot)
