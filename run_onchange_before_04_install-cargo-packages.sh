#!/bin/bash
# Install cargo packages: ripgrep, bat, git-delta, zoxide

# Source cargo env in case it was just installed by install-rust.sh
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

if ! command -v cargo > /dev/null 2>&1; then
  echo "cargo not found — skipping ripgrep, bat, git-delta, zoxide"
  exit 0
fi

# pkg:binary pairs
install_cargo_pkg() {
  local pkg="$1" bin="$2"
  if command -v "$bin" > /dev/null 2>&1; then
    echo "$pkg is already installed: $(command -v "$bin")"
  else
    echo "Installing $pkg via cargo..."
    cargo install "$pkg"
  fi
}

install_cargo_pkg ripgrep rg
install_cargo_pkg bat bat
install_cargo_pkg git-delta delta
install_cargo_pkg zoxide zoxide
