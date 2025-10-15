local specs = {
	rootMountPoint = "/mnt",
	rootPart = "/dev/nvme0n1p8",
	rootLabel = "ARCH",
	esp = "/dev/nvme0n1p9",
	espMountPoint = "/boot",
	espLabel = "ESP",
	parallelDownloads = 30,
	bootLoader = "systemdboot",
	user = "arch",
	userShell = "/bin/fish",
	hostname = "thebasement",
	timezone = "Asia/Kolkata",
	locale = "en_US.UTF-8 UTF-8",
	lang = "en_US.UTF-8",
	enable = {"NetworkManager"}
}

specs["packages"] = dofile("packages.lua)
local chroot = string.format("arch-chroot %s", specs.rootMountPoint)
local steps = {}
steps[1] = {
	command = string.format("mkfs.ext4 -L %s %s", specs.rootLabel, specs.rootPart),
	desc = "formatRoot"
}
steps[2] = {
	command = string.format("mkfs.fat -F 32 -n %s %s", specs.espLabel, specs.esp),
	desc = "formatESP",
	disabled = specs.espLabel == nil
}
steps[3] = {
	command = string.format("mount %s %s", specs.rootPart, specs.rootMountPoint),
	desc = "mountRoot"
}
steps[4] = {
	command = string.format("mount --mkdir %s %s%s", specs.esp, specs.rootMountPoint, specs.espMountPoint),
	desc = "mountESP"
}
steps[5] = {
	command = string.format("sed -i 's/^.*ParallelDownload.*$/ParallelDownloads = %s/' /etc/pacman.conf",
		specs.parallelDownloads),
	desc = "enableParallelDownload"
}
steps[6] = {
	command = string.format("pacstrap -P -K %s %s", specs.rootMountPoint, table.concat(specs.packages, " ")),
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
	command = string.format("%s useradd -m -G wheel %s -s %s", chroot, specs.user, specs.userShell),
	desc = "useradd"
}
steps[10] = {
	command = string.format("%s hwclock --systohc", chroot),
	desc = "hwclock"
}
steps[11] = {
	command = string.format("echo %s >> %s/etc/locale.gen", specs.locale, specs.rootMountPoint),
	desc = "locale"
}
steps[12] = {
	command = string.format("%s locale-gen", chroot),
	desc = "localeGen",
}
steps[13] = {
	command = string.format("echo 'LANG = %s' > %s/etc/locale.conf", specs.lang, specs.rootMountPoint),
	desc = "lang"
}
steps[14] = {
	command = string.format("echo %s > %s/etc/hostname", specs.hostname, specs.rootMountPoint),
	desc = "hostname"
}
steps[15] = {
	command = string.format("%s passwd", chroot),
	desc = "passwd"
}
steps[16] = {
	command = string.format("%s passwd %s", chroot, specs.user),
}
if specs.bootLoader == "grub" then
	steps[17] = {
		command = string.format("%s grub-install --efi-directory=%s", chroot, specs.espMountPoint),
	}
	steps[18] = {
		command = string.format("%s grub-mkconfig -o %s/grub/grub.cfg", chroot, specs.espMountPoint),
	}
end
if specs.bootLoader == "systemdboot" then
	local loaderConf = "default\t\tarch.conf\ntimeout\t\t0.1"
	local archConf = string.format(
	"title\t\tArch Linux\nlinux\t\t/vmlinuz-linux\ninitrd\t\t/initramfs-linux.img\noptions\t\troot=LABEL=%s rw quiet",
		specs.rootLabel)
	steps[17] = {
		command = string.format("%s bootctl install", chroot),
	}
	steps[18] = {
		command = string.format(
		"echo '%s' > %s%s/loader/loader.conf && mkdir -p %s%s/loader/entries && echo '%s' > %s%s/loader/entries/arch.conf",
			loaderConf, specs.rootMountPoint, specs.espMountPoint, specs.rootMountPoint, specs.espMountPoint, archConf,
			specs.rootMountPoint, specs.espMountPoint),
	}
end
steps[19] = {
	command = string.format("%s systemctl enable %s", chroot, table.concat(specs.enable, " ")),
	desc = "systemd enable"
}
steps[20] = {
	command = string.format("sed -i 's/^.*wheel ALL=(ALL:ALL) ALL.*$/%%wheel ALL=(ALL:ALL) ALL/' %s/etc/sudoers", specs.rootMountPoint)
}

for i = 1, 20 do
	if steps[i] ~= nil and steps[i].disabled ~= true then
		print(steps[i].command)
		local code = os.execute(steps[i].command)
		if code ~= true then
			break
		end
	else
		print(steps[i].disabled)
	end
end
os.execute(string.format("umount -l %s", specs.rootMountPoint))
