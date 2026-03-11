ZPLUGINDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"

# Initialize zsh completion system
autoload -U compinit && compinit

# fzf-tab (must be after compinit, before other widgets)
source "$ZPLUGINDIR/fzf-tab/fzf-tab.plugin.zsh"

# zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source "$ZPLUGINDIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting (must be last)
source "$ZPLUGINDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
