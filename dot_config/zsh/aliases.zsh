alias vi=nvim

# Prefer GNU ls (brew coreutils on macOS): it sizes each column separately,
# while BSD ls pads every column to the longest name.
if command -v gls >/dev/null 2>&1; then
  alias ls='gls --color=auto'
else
  alias ls='ls --color=auto'
fi

# List the new directory after every cd/pushd/popd (zoxide jumps included).
# Defined after the ls alias so the alias expands inside the function body.
ls_on_chpwd() { ls }
autoload -Uz add-zsh-hook
add-zsh-hook chpwd ls_on_chpwd
