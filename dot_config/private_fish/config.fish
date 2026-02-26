set -x EDITOR nvim
set -x BAT_THEME Dracula

fish_config theme choose "Dracula Official"
nvm use latest
. "$HOME/.cargo/env.fish"

set -gx PATH $PATH $HOME/.krew/bin
set -gx KUBECONFIG $HOME/mif/kubeconfig.yaml
set -gx KUBENS inhyeok

# opencode
fish_add_path /home/inhyeok/.opencode/bin
