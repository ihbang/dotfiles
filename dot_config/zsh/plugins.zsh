ZPLUGINDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"

# zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source "$ZPLUGINDIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# fzf-tab
source "$ZPLUGINDIR/fzf-tab/fzf-tab.plugin.zsh"

# zsh-syntax-highlighting (must be last)
source "$ZPLUGINDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
