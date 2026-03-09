export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CUSTOM="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh-custom"

# Dracula: oh-my-zsh looks for $ZSH_CUSTOM/themes/dracula.zsh-theme (flat path).
# The repo is cloned into themes/dracula/, so we symlink the theme file.
local dracula_src="$ZSH_CUSTOM/themes/dracula/dracula.zsh-theme"
local dracula_dst="$ZSH_CUSTOM/themes/dracula.zsh-theme"
[[ -f "$dracula_src" && ! -e "$dracula_dst" ]] && ln -sf "$dracula_src" "$dracula_dst"

ZSH_THEME="dracula"

plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting  # must be last
)

source "$ZSH/oh-my-zsh.sh"
