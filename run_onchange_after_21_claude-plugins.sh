#!/bin/bash
# Declare the Claude Code marketplaces and plugins this machine should have.
#
# Only the lists live here. The marketplace clones and the plugin cache under
# ~/.claude/plugins come to a few hundred megabytes and are re-fetched from
# GitHub anyway, and installed_plugins.json records absolute paths and commit
# SHAs that do not travel, so none of it is checked in.
#
# Out of scope: plugins whose scope is "synced" arrive from claude.ai and are
# managed by Claude Code itself, and marketplaces that back no installed plugin
# are left out rather than cloned for nothing.

if ! command -v claude >/dev/null 2>&1; then
  echo "claude is not installed; skipping plugin setup"
  exit 0
fi

# Local name, then the source to add it from. The name is declared by the
# marketplace rather than derived from the repo, which is why it is spelled out
# here: it is what both the lookup below and the plugin ids match on.
MARKETPLACES=(
  "a2sys-claude a2sys-platform/claude-plugins"
  "agricidaniel-claude-obsidian AgriciDaniel/claude-obsidian"
  "anthropic-agent-skills anthropics/skills"
  "claude-community anthropics/claude-plugins-community"
  "claude-plugins-official anthropics/claude-plugins-official"
  "frontend-slides https://github.com/zarazhangrui/frontend-slides.git"
  "i-have-adhd ayghri/i-have-adhd"
  "im-not-ai epoko77-ai/im-not-ai"
)

PLUGINS=(
  "claude-obsidian@agricidaniel-claude-obsidian"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "core@a2sys-claude"
  "document-skills@anthropic-agent-skills"
  "documents@a2sys-claude"
  "eli5@claude-community"
  "example-skills@anthropic-agent-skills"
  "frontend-slides@frontend-slides"
  "humanize-korean@im-not-ai"
  "humanizer@a2sys-claude"
  "i-have-adhd@i-have-adhd"
  "mattpocock-skills@claude-plugins-official"
)

# ── marketplaces ──────────────────────────────────────────────────────────────

add_marketplaces() {
  local listed name source
  listed=$(claude plugin marketplace list --json 2>/dev/null)

  local entry
  for entry in "${MARKETPLACES[@]}"; do
    name=${entry%% *}
    source=${entry#* }

    if printf '%s' "$listed" | grep -q "\"name\"[[:space:]]*:[[:space:]]*\"${name}\""; then
      echo "marketplace $name is already configured"
      continue
    fi

    echo "Adding marketplace $name ($source)..."
    claude plugin marketplace add "$source" ||
      echo "marketplace $name: add failed"
  done
}

# ── plugins ───────────────────────────────────────────────────────────────────

install_plugins() {
  local listed
  listed=$(claude plugin list --json 2>/dev/null)

  local id
  for id in "${PLUGINS[@]}"; do
    if printf '%s' "$listed" | grep -q "\"id\"[[:space:]]*:[[:space:]]*\"${id}\""; then
      echo "plugin $id is already installed"
      continue
    fi

    echo "Installing plugin $id..."
    # No --yes on purpose: that flag blanket-accepts whatever command a
    # marketplace declares for its install. A plugin that needs one has to be
    # installed by hand, having read the command.
    claude plugin install "$id" --scope user || {
      echo "plugin $id: install failed — if it wants a marketplace-declared"
      echo "    command, run 'claude plugin install $id' and read the prompt."
    }
  done
}

# ── main ──────────────────────────────────────────────────────────────────────

add_marketplaces
install_plugins
