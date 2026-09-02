# History
# macOS ships HISTFILE/HISTSIZE/SAVEHIST in /etc/zshrc, but that file is not
# managed by chezmoi and has no counterpart on the remote servers -- especially
# when zsh is built from source into ~/.local, where sysconfdir points at
# ~/.local/etc and no system zshrc exists at all. Without these, zsh defaults to
# an empty HISTFILE and SAVEHIST=0, so history never reaches disk.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY          # share history across concurrent sessions
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates of a repeated command
setopt HIST_IGNORE_SPACE      # skip commands prefixed with a space
setopt HIST_REDUCE_BLANKS     # strip superfluous whitespace before storing
setopt EXTENDED_HISTORY       # record timestamp and duration per entry
