#!/bin/bash
# Install global npm packages: @openai/codex

# Source nvm in case node was just installed by install-binaries.sh; chezmoi
# runs this in a non-interactive shell, so dot_zshrc has not loaded it.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found — skipping @openai/codex"
  exit 0
fi

# Globals live under the active node version, so they do not survive an
# nvm upgrade to a new major; re-run this script after one.
install_npm_pkg() {
  local pkg="$1" bin="$2"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "$pkg is already installed: $(command -v "$bin")"
  else
    echo "Installing $pkg via npm..."
    npm install -g "$pkg"
  fi
}

install_npm_pkg @openai/codex codex
