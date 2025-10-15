local basic = table.concat({"base", "base-devel", "linux", "linux-firmware", "network-manager-applet", "networkmanager", "ntfs-3g", "wl-clipboard", "wlroots0.19", "pavucontrol", "polkit-gnome", "pulseaudio", "pulseaudio-bluetooth", "trash-cli", "unzip"}, " ")
local utils = table.concat({"alacritty", "atool", "git", "gnome-disk-utility", "gpart", "zip", "brightnessctl", "caja", "dosfstools", "engrampa", "evince", "fish", "fuzzel", "kitty", "man-db", "openvpn", "networkmanager-openvpn", "wget", "waylock", "wayland-protocols"}, " ")
local cosmetic = table.concat({"nwg-look", "waybar", "wpaperd", "tree", "mako", "slurp" }, " ")
local tools = table.concat({"grim", "gthumb", "htop", "imv", "inkscape", "nodejs", "mpv", "neovim" }, " ")
return basic .. utils .. cosmetic .. tools
