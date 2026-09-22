#!/bin/bash
# Install packages that have no standalone binary release, via the OS package manager.
#
# poppler provides pdftoppm, which Claude Code's Read tool needs to render PDFs.
# It is a C++ library with no prebuilt release artifacts, so it cannot go in
# run_onchange_before_03_install-binaries.sh with the rest.
#
# jq is what dot_claude/executable_awesome-statusline.sh and the settings.json
# hooks parse their JSON input with, so the status line is blank without it.

OS=$(uname -s)

case "$OS" in
Darwin)
  if command -v pdftoppm >/dev/null 2>&1; then
    echo "poppler is already installed: $(command -v pdftoppm)"
  else
    echo "Installing poppler..."
    brew install poppler
  fi

  # GNU ls (gls) sizes each column to its own contents; the BSD ls that ships
  # with macOS pads every column to the longest name, so gaps look uneven.
  # aliases.zsh prefers gls when it is present.
  if command -v gls >/dev/null 2>&1; then
    echo "coreutils is already installed: $(command -v gls)"
  else
    echo "Installing coreutils..."
    brew install coreutils
  fi

  if command -v jq >/dev/null 2>&1; then
    echo "jq is already installed: $(command -v jq)"
  else
    echo "Installing jq..."
    brew install jq
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

  if command -v jq >/dev/null 2>&1; then
    echo "jq is already installed: $(command -v jq)"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "Installing jq..."
    sudo apt-get update -qq && sudo apt-get install -y jq
  elif command -v dnf >/dev/null 2>&1; then
    echo "Installing jq..."
    sudo dnf install -y jq
  else
    echo "jq: no supported package manager found; install jq manually"
  fi
  ;;
*)
  echo "poppler, jq: unsupported OS $OS"
  ;;
esac
