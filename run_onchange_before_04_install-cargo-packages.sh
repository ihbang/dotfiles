#!/bin/bash
# Install cargo packages: ripgrep, bat, git-delta

# Source cargo env in case it was just installed by install-rust.sh
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

if ! command -v cargo > /dev/null 2>&1; then
  echo "cargo not found — skipping ripgrep, bat, git-delta"
  exit 0
fi

# pkg -> binary name
declare -A packages=(
  [ripgrep]=rg
  [bat]=bat
  [git-delta]=delta
)

for pkg in "${!packages[@]}"; do
  bin="${packages[$pkg]}"
  if command -v "$bin" > /dev/null 2>&1; then
    echo "$pkg is already installed: $(command -v "$bin")"
  else
    echo "Installing $pkg via cargo..."
    cargo install "$pkg"
  fi
done
