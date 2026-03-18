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

# ── lazygit ───────────────────────────────────────────────────────────────────

install_lazygit() {
  if command -v lazygit > /dev/null 2>&1; then
    echo "lazygit is already installed: $(command -v lazygit)"
    return 0
  fi

  local os_suffix arch_suffix
  case "$OS" in
    Linux)  os_suffix="linux" ;;
    Darwin) os_suffix="darwin" ;;
    *) echo "lazygit: unsupported OS $OS"; return 1 ;;
  esac
  case "$ARCH" in
    x86_64)        arch_suffix="x86_64" ;;
    aarch64|arm64) arch_suffix="arm64" ;;
    *) echo "lazygit: unsupported arch $ARCH"; return 1 ;;
  esac

  local version
  version=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') \
    || { echo "lazygit: failed to fetch latest version"; return 1; }

  local asset="lazygit_${version}_${os_suffix}_${arch_suffix}.tar.gz"

  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  echo "Installing lazygit v${version}..."
  curl -fsSL \
    "https://github.com/jesseduffield/lazygit/releases/download/v${version}/${asset}" \
    -o "$tmp/lazygit.tar.gz" || { echo "lazygit: download failed"; return 1; }

  tar -xf "$tmp/lazygit.tar.gz" -C "$tmp"
  install -m 755 "$tmp/lazygit" "$INSTALL_PREFIX/bin/lazygit"

  echo "lazygit installed to $INSTALL_PREFIX/bin/lazygit"
}

# ── glow ──────────────────────────────────────────────────────────────────────

install_glow() {
  if command -v glow > /dev/null 2>&1; then
    echo "glow is already installed: $(command -v glow)"
    return 0
  fi

  local os_suffix arch_suffix
  case "$OS" in
    Linux)  os_suffix="Linux" ;;
    Darwin) os_suffix="Darwin" ;;
    *) echo "glow: unsupported OS $OS"; return 1 ;;
  esac
  case "$ARCH" in
    x86_64)        arch_suffix="x86_64" ;;
    aarch64|arm64) arch_suffix="arm64" ;;
    *) echo "glow: unsupported arch $ARCH"; return 1 ;;
  esac

  local version
  version=$(curl -fsSL https://api.github.com/repos/charmbracelet/glow/releases/latest \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') \
    || { echo "glow: failed to fetch latest version"; return 1; }

  local asset="glow_${version}_${os_suffix}_${arch_suffix}.tar.gz"

  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN

  echo "Installing glow v${version}..."
  curl -fsSL \
    "https://github.com/charmbracelet/glow/releases/download/v${version}/${asset}" \
    -o "$tmp/glow.tar.gz" || { echo "glow: download failed"; return 1; }

  tar -xf "$tmp/glow.tar.gz" -C "$tmp"
  install -m 755 "$(find "$tmp" -name glow -type f)" "$INSTALL_PREFIX/bin/glow"

  echo "glow installed to $INSTALL_PREFIX/bin/glow"
}

# ── nvm + node ────────────────────────────────────────────────────────────────

install_nvm() {
  if [ -d "$HOME/.nvm" ]; then
    echo "nvm is already installed: $HOME/.nvm"
    return 0
  fi

  echo "Installing nvm (latest)..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash \
    || { echo "nvm: install failed"; return 1; }

  # Load nvm and install latest LTS node
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  echo "Installing Node.js LTS via nvm..."
  nvm install --lts

  echo "nvm + Node.js LTS installed"
}

# ── main ──────────────────────────────────────────────────────────────────────

install_neovim
install_fzf
install_starship
install_lazygit
install_glow
install_nvm
