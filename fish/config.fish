set target_paths "/usr/local/bin" "$HOME/.local/bin" "$HOME/storage/texlive/2025/bin/x86_64-linux" "$HOME/storage/.juliaup/bin"

for target_path in $target_paths
	if test -d "$target_path"
		# Check if the path is not already in $fish_user_paths to avoid duplicates
		if not contains "$target_path" $PATH
			set -gx PATH "$target_path" $PATH
		end
	end
end
#### ENV VARIABLES ####
set -gx EDITOR "nvim"
set -gx VISUAL "nvim"
set -gx JULIA_PKG_USE_CLI_GIT "true"
set -gx QT_QPA_PLATFORMTHEME "qt5ct"
set -gx MOZ_ENABLE_WAYLAND "1"
set -gx QT_QPA_PLATFORM "wayland"
set -gx SDL_VIDEODRIVER "wayland"
set -gx XDG_SESSION_TYPE "wayland"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"

#### ALIASES ####
abbr --add grep "grep -i --color=always"
abbr --add uvlatest "source ~/.p315/bin/activate.fish"
abbr --add uvnogil "source ~/.pnogil/bin/activate.fish"
abbr burn "sudo dd bs=4M conv=fdatasync status=progress if="
abbr jl "julialauncher"

function ls
    tree -L 1 -C -h --du -a -D $argv | column
end

#### START WAYLAND COMPOSITOR ####
if status --is-login
	if test -z "$DISPLAY" -a $XDG_VTNR = 1
		pulseaudio --start -D
		exec dwl -s dwl-start.sh
	end
end

set fish_greeting
