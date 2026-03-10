export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CUSTOM="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh-custom"

ZSH_THEME=""  # prompt is handled by starship

plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting  # must be last
)

source "$ZSH/oh-my-zsh.sh"
