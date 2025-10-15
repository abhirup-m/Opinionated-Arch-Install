fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin

#### ENV VARIABLES ####
set -gx EDITOR "nvim"
set -gx VISUAL "nvim"
set -gx JULIA_PKG_USE_CLI_GIT "true"
set -gx QT_QPA_PLATFORMTHEME "qt6ct"
set -gx MOZ_ENABLE_WAYLAND "1"
set -gx QT_QPA_PLATFORM "wayland"
set -gx SDL_VIDEODRIVER "wayland"
set -gx XDG_SESSION_TYPE "wayland"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"

#### ALIASES ####
alias ls "tree -L 1 -C -h --du -a -D | column"
alias mpython "$HOME/storage/miniconda3/bin/python"
alias mpip "$HOME/storage/miniconda3/bin/pip"

#### START WAYLAND COMPOSITOR ####
if status --is-login
	if test -z "$DISPLAY" -a $XDG_VTNR = 1
		pulseaudio --start -D
		exec dwl -s dwl-start.sh
	end
end

set fish_greeting
