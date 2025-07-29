#!/bin/sh

# This script sets up a development environment by first verifying that all
# essential system dependencies are met, and then using 'asdf' to install
# developer tools into the user's home directory.
# It does NOT install system packages automatically.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Helper function to check if a command exists ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- 1. Check for Required System Dependencies ---
echo "--> Step 1: Verifying essential system dependencies..."

# List of essential commands and the packages that provide them on Debian/Ubuntu.
# Format: <command_to_check>:<example_package_name>
ESSENTIALS="git:git gcc:build-essential curl:curl"

all_deps_met=true
for item in $ESSENTIALS; do
  cmd=$(echo "$item" | cut -d: -f1)
  pkg=$(echo "$item" | cut -d: -f2)
  if ! command_exists "$cmd"; then
    echo "Error: Required command '$cmd' is not found."
    echo "       Please install it manually. e.g., on Debian/Ubuntu: sudo apt install $pkg"
    all_deps_met=false
  fi
done

# Check for optional but recommended tools
RECOMMENDED="fish:fish"
for item in $RECOMMENDED; do
  cmd=$(echo "$item" | cut -d: -f1)
  pkg=$(echo "$item" | cut -d: -f2)
  if ! command_exists "$cmd"; then
    echo "Warning: Recommended tool '$cmd' is not found."
    echo "         For the best experience, please install it manually (e.g., sudo apt install $pkg)."
  fi
done

# On Linux, extra build libraries are often needed.
if [ "$(uname)" = "Linux" ]; then
  # We can't easily check for library headers, so we inform the user.
  echo "Info: On Linux, ensure you have build libraries like 'pkg-config', 'libssl-dev', and 'zlib1g-dev' installed."
fi

if [ "$all_deps_met" = "false" ]; then
  echo ""
  echo "Fatal: Missing one or more essential system dependencies."
  echo "       Please install the required packages and re-run this script."
  exit 1
fi

echo "All essential dependencies are met."

# --- 2. Install Rust Environment via rustup ---
echo "--> Step 2: Setting up Rust environment..."
if ! command_exists "cargo"; then
  echo "Installing rustup (which includes rustc and cargo)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
else
  echo "Rust environment (cargo) is already installed."
fi
# Source cargo env to make it available in the current script
. "$HOME/.cargo/env"

# --- 3. Install Rust-based tools via cargo ---
echo "--> Step 3: Installing Rust-based tools via cargo..."
CARGO_TOOLS="ripgrep:rg bat:bat fd-find:fd git-delta:delta"
for tool_info in $CARGO_TOOLS; do
  pkg_name=$(echo "$tool_info" | cut -d: -f1)
  cmd_name=$(echo "$tool_info" | cut -d: -f2)
  if ! command_exists "$cmd_name"; then
    echo "Installing $pkg_name via cargo..."
    cargo install "$pkg_name"
  else
    echo "$cmd_name is already installed. Skipping."
  fi
done

# --- 4. Install asdf and all tools defined in .tool-versions ---
echo "--> Step 2: Setting up asdf version manager..."
ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.18.0"
LOCAL_BIN_PATH="$HOME/.local/bin"
if [ "$(uname)" = "Darwin" ]; then
  if ! command_exists "brew"; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -x "/opt/homebrew/bin/brew" ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

  if ! command_exists "asdf"; then
    echo "Installing asdf via Homebrew..."
    brew install asdf
  else
    echo "asdf is already installed via Homebrew. Updating..."
    brew upgrade asdf
  fi
else
  install_asdf=false
  if command_exists "asdf"; then
    asdf_bin=$(which asdf)
    current_version=$($asdf_bin -v | cut -d' ' -f3)
    if [ "$current_version" != "$ASDF_VERSION" ]; then
      echo "Incorrect asdf version ($current_version) found. Expected $ASDF_VERSION. Re-installing..."
      rm -rf "$asdf_bin"
      install_asdf=true
    fi
  else
    install_asdf=true
  fi

  if [ "$install_asdf" = true ]; then
    echo "Download prebuilt asdf binary at version $ASDF_VERSION..."
    wget "https://github.com/asdf-vm/asdf/releases/download/$ASDF_VERSION/asdf-$ASDF_VERSION-linux-amd64.tar.gz"
    tar xvzf asdf-$ASDF_VERSION-linux-amd64.tar.gz
    mkdir -p $LOCAL_BIN_PATH && mv asdf $LOCAL_BIN_PATH
    rm -rf asdf-$ASDF_VERSION-linux-amd64.tar.gz
  fi
fi

TOOL_VERSIONS_FILE="$HOME/.tool-versions"
if [ ! -f "$TOOL_VERSIONS_FILE" ]; then
  echo "Warning: .tool-versions file not found. Skipping dev tool installation."
  exit 0
fi

echo "Installing asdf plugins and tools from $TOOL_VERSIONS_FILE..."

# Add plugins for each tool in the file
cat "$TOOL_VERSIONS_FILE" | grep -v '^#' | cut -d' ' -f1 | while read -r tool_name; do
  if ! asdf plugin list | grep -q "^$tool_name$"; then
    echo "Adding asdf plugin for $tool_name..."
    asdf plugin add "$tool_name"
  fi
done

# Install all tools defined in the file
echo "Installing all tools with asdf..."
asdf install

echo "All tools are now installed and managed by asdf."
echo "--> Setup process finished!"
