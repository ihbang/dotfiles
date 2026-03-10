#!/bin/bash
# Install binary tools to ~/.local: neovim, fzf, starship

INSTALL_PREFIX="$HOME/.local"
mkdir -p "$INSTALL_PREFIX/bin"

OS=$(uname -s)
ARCH=$(uname -m)

# ── neovim ────────────────────────────────────────────────────────────────────

install_neovim() {
  if command -v nvim > /dev/null 2>&1; then
    echo "neovim is already installed: $(command -v nvim)"
    return 0
  fi

  local asset

  case "$OS-$ARCH" in
    Linux-x86_64)   asset="nvim-linux-x86_64.tar.gz" ;;
    Linux-aarch64)  asset="nvim-linux-arm64.tar.gz" ;;
    Darwin-x86_64)  asset="nvim-macos-x86_64.tar.gz" ;;
    Darwin-arm64)   asset="nvim-macos-arm64.tar.gz" ;;
    *) echo "neovim: unsupported platform $OS-$ARCH"; return 1 ;;
  esac

  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  echo "Installing neovim (latest)..."
  curl -fsSL \
    "https://github.com/neovim/neovim/releases/latest/download/${asset}" \
    -o "$tmp/nvim.tar.gz"

  tar -xf "$tmp/nvim.tar.gz" -C "$tmp"

  # tarball extracts to nvim-linux-x86_64/ or nvim-macos-arm64/ etc.
  local extracted
  extracted=$(find "$tmp" -maxdepth 1 -type d -name "nvim-*")
  cp -r "$extracted/." "$INSTALL_PREFIX/"

  echo "neovim installed to $INSTALL_PREFIX/bin/nvim"
}

# ── fzf ───────────────────────────────────────────────────────────────────────

install_fzf() {
  if command -v fzf > /dev/null 2>&1; then
    echo "fzf is already installed: $(command -v fzf)"
    return 0
  fi

  echo "Installing fzf (latest)..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"

  # --bin: install binary only, skip shell integration (managed by chezmoi)
  "$HOME/.fzf/install" --bin

  ln -sf "$HOME/.fzf/bin/fzf" "$INSTALL_PREFIX/bin/fzf"

  echo "fzf installed to $INSTALL_PREFIX/bin/fzf"
}

# ── starship ──────────────────────────────────────────────────────────────────

install_starship() {
  if command -v starship > /dev/null 2>&1; then
    echo "starship is already installed: $(command -v starship)"
    return 0
  fi

  echo "Installing starship (latest)..."
  curl -sS https://starship.rs/install.sh \
    | sh -s -- --bin-dir "$INSTALL_PREFIX/bin" --yes

  echo "starship installed to $INSTALL_PREFIX/bin/starship"
}

# ── main ──────────────────────────────────────────────────────────────────────

install_neovim
install_fzf
install_starship
