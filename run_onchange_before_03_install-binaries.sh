#!/bin/bash
# Install binary tools to ~/.local: neovim, fzf

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

  local version="0.10.4"
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

  echo "Installing neovim ${version}..."
  curl -fsSL \
    "https://github.com/neovim/neovim/releases/download/v${version}/${asset}" \
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

  local version="0.57.0"
  local asset

  case "$OS-$ARCH" in
    Linux-x86_64)   asset="fzf-${version}-linux_amd64.tar.gz" ;;
    Linux-aarch64)  asset="fzf-${version}-linux_arm64.tar.gz" ;;
    Darwin-x86_64)  asset="fzf-${version}-darwin_amd64.tar.gz" ;;
    Darwin-arm64)   asset="fzf-${version}-darwin_arm64.tar.gz" ;;
    *) echo "fzf: unsupported platform $OS-$ARCH"; return 1 ;;
  esac

  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  echo "Installing fzf ${version}..."
  curl -fsSL \
    "https://github.com/junegunn/fzf/releases/download/v${version}/${asset}" \
    -o "$tmp/fzf.tar.gz"

  tar -xf "$tmp/fzf.tar.gz" -C "$INSTALL_PREFIX/bin" fzf

  echo "fzf installed to $INSTALL_PREFIX/bin/fzf"
}

# ── main ──────────────────────────────────────────────────────────────────────

install_neovim
install_fzf
