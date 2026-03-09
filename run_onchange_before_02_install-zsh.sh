#!/bin/sh
# Install zsh to ~/.local if not already available

if command -v zsh > /dev/null 2>&1; then
  echo "zsh is already installed: $(command -v zsh)"
  exit 0
fi

ZSH_VERSION="5.9"
ZSH_PREFIX="$HOME/.local"
ZSH_SRC_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$ZSH_SRC_DIR"
}
trap cleanup EXIT

echo "zsh not found. Installing zsh ${ZSH_VERSION} to ${ZSH_PREFIX} ..."

# Download
curl -fsSL "https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz/download" \
  -o "${ZSH_SRC_DIR}/zsh.tar.xz"

# Extract
tar -xf "${ZSH_SRC_DIR}/zsh.tar.xz" -C "$ZSH_SRC_DIR"

# Build and install
cd "${ZSH_SRC_DIR}/zsh-${ZSH_VERSION}"

./configure \
  --prefix="$ZSH_PREFIX" \
  --bindir="$ZSH_PREFIX/bin" \
  --enable-multibyte \
  --enable-zsh-secure-free

make -j"$(nproc 2>/dev/null || echo 2)"
make install

echo "zsh installed to ${ZSH_PREFIX}/bin/zsh"
