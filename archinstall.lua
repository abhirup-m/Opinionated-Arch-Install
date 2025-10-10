local specs = {
    rootMountPoint = "/mnt",
    rootPart = "/dev/nvme0n1p8",
	rootLabel = "ARCH",
    esp = nil,
	espMountPoint = "/mnt/boot",
	espLabel = "ESP",
	parallelDownloads = 30,
	packages = {"base", "linux", "linux-firmware", "fish"},
	bootLoader = "grub",
	user = "arch",
	userShell = "/bin/fish",
	hostname = "thebasement",
	timezone = "Asia/Kolkata",
	locale = "en_US.UTF-8 UTF-8",
	lang = "en_US.UTF-8",
}

local chroot = string.format("arch-chroot %s", specs.rootMountPoint)
local steps = {}
steps[1] = {
	command = string.format("mkfs.ext4 -L %s %s", specs.rootLabel, specs.rootPart),
	desc = "formatRoot"
}
steps[2] = {
	command = string.format("mkfs.fat -F 32 -L %s %s", specs.espLabel, specs.esp),
	desc = "formatESP"
}
steps[3] = {
	command = string.format("mount %s %s", specs.rootPart, specs.rootMountPoint),
	desc = "mountRoot"
}
steps[4] = {
	command = string.format("mount --mkdir %s %s", specs.esp, specs.espMountPoint),
	desc = "mountESP"
}
steps[5] = {
	command = string.format("sed -i 's/^.*ParallelDownload.*$/ParallelDownloads = %s/' /etc/pacman.conf", specs.parallelDownloads),
	desc = "enableParallelDownload"
}
steps[6] = {
	command = string.format("pactstrap -P -K %s %s", specs.rootMountPoint, table.concat(specs.packages, " ")),
	desc = "pactstrap"
}
steps[7] = {
	command = string.format("genfstab %s > %s/etc/fstab", specs.rootMountPoint, specs.rootMountPoint),
	desc = "genfstab"
}
steps[8] = {
	command = string.format("%s ln -sf /usr/share/zoneinfo/%s /etc/localtime", chroot, specs.timezone),
	desc = "timezone"
}
steps[9] = {
	command = string.format("useradd -m -G wheel %s -s %s && passwd %s", specs.user, specs.userShell, specs.user),
	desc = "useradd"
}
steps[10] = {
	command = "%s hwclock --systohc",
	desc = "hwclock"
}
steps[11] = {
	command = string.format("%s echo %s >> /etc/locale.gen", chroot, specs.locale),
	desc = "locale"
}
steps[12] = {
	command = "%s locale-gen",
	desc = "localeGen",
}
steps[13] = {
	command = string.format("%s echo 'LANG = %s' > /etc/locale.conf", chroot, specs.lang),
	desc = "lang"
}
steps[14] = {
	command = string.format("%s echo %s > /etc/hostname", chroot, specs.hostname),
	desc = "hostname"
}
steps[15] = {
	command = string.format("%s passwd", chroot),
	desc = "passwd"
}

for i = 1, 15 do
	print(steps[i].desc)
	local code = os.execute(steps[i].command)
	if code ~= true then
		os.exit()
	end
end

