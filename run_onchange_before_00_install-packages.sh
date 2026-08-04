#!/bin/bash
# Install packages that have no standalone binary release, via the OS package manager.
#
# poppler provides pdftoppm, which Claude Code's Read tool needs to render PDFs.
# It is a C++ library with no prebuilt release artifacts, so it cannot go in
# run_onchange_before_03_install-binaries.sh with the rest.

OS=$(uname -s)

case "$OS" in
Darwin)
  if command -v pdftoppm >/dev/null 2>&1; then
    echo "poppler is already installed: $(command -v pdftoppm)"
  else
    echo "Installing poppler..."
    brew install poppler
  fi
  ;;
Linux)
  if command -v pdftoppm >/dev/null 2>&1; then
    echo "poppler is already installed: $(command -v pdftoppm)"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "Installing poppler-utils..."
    sudo apt-get update -qq && sudo apt-get install -y poppler-utils
  elif command -v dnf >/dev/null 2>&1; then
    echo "Installing poppler-utils..."
    sudo dnf install -y poppler-utils
  else
    echo "poppler: no supported package manager found; install poppler-utils manually"
  fi
  ;;
*)
  echo "poppler: unsupported OS $OS"
  ;;
esac
