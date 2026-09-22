#!/bin/bash
# Set up the two parts of herdr that config.toml depends on but cannot carry:
# the Claude Code integration hook and the herdr-nvim plugin.
#
# Neither is a file chezmoi can own. herdr generates the hook script itself and
# overwrites it whenever the integration version changes, and plugins are
# unpacked under ~/.config/herdr/plugins with absolute paths and a resolved
# commit baked in. So this script records that both must exist and leaves their
# contents to herdr. Runs after apply, once config.toml is in place.

if ! command -v herdr >/dev/null 2>&1; then
  echo "herdr is not installed; skipping herdr setup"
  exit 0
fi

# ── claude code integration ───────────────────────────────────────────────────

# Installs $CLAUDE_CONFIG_DIR/hooks/herdr-agent-state.sh, which reports the agent
# session to the running server. "current" means the installed hook matches the
# integration version this herdr build ships.
setup_integration() {
  if herdr integration status 2>/dev/null | grep -q '^claude: current'; then
    echo "herdr claude integration is already current"
    return 0
  fi

  echo "Installing the herdr claude integration..."
  herdr integration install claude || {
    echo "herdr: claude integration install failed"
    return 1
  }
}

# ── herdr-nvim plugin ─────────────────────────────────────────────────────────

# config.toml binds prefix+e and prefix+o to this plugin's actions, so without it
# both keys are dead. Installed unpinned, like every other tool in this repo.
setup_nvim_plugin() {
  if herdr plugin list --json 2>/dev/null | grep -q '"plugin_id":"chmarax.herdr-nvim"'; then
    echo "herdr-nvim is already installed"
    return 0
  fi

  echo "Installing herdr-nvim..."
  herdr plugin install ChmaraX/herdr-nvim --yes || {
    echo "herdr: herdr-nvim install failed"
    return 1
  }
}

# ── main ──────────────────────────────────────────────────────────────────────

setup_integration
setup_nvim_plugin
