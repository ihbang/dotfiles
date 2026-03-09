#!/bin/sh
# Install Rust toolchain via rustup if cargo is not available

if command -v cargo > /dev/null 2>&1; then
  echo "cargo is already installed: $(command -v cargo)"
  exit 0
fi

echo "Installing Rust via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --no-modify-path

echo "Rust installed to $HOME/.cargo"
