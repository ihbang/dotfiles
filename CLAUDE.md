# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A [chezmoi](https://chezmoi.io) dotfiles repository. Chezmoi manages dotfiles by mapping source files to target locations in `$HOME`. Changes here are applied by running `chezmoi apply`.

## Do Not Use Worktrees In This Repo

Edit files directly in the primary checkout (`~/.local/share/chezmoi`). Never move this
repository's work into a git worktree.

Chezmoi resolves its source directory to that one fixed path, so a file edited in a worktree
is invisible to `chezmoi apply` — the change cannot reach `$HOME` until the commit lands back
on `main` in the primary checkout. A worktree buys isolation here at the cost of breaking the
only path this repo has to production.

This overrides any global "always work in a worktree" instruction.

## Key Commands

```sh
# Apply all dotfiles to $HOME
chezmoi apply

# Preview what would change before applying
chezmoi diff

# Edit a managed file (opens in $EDITOR, auto-applies on save)
chezmoi edit ~/.zshrc

# Add a new file to be managed
chezmoi add ~/.some-new-config

# Re-run all onchange scripts (e.g. after modifying install scripts)
chezmoi apply --force
```

## File Naming Conventions

Chezmoi uses prefixes to encode how source files map to targets:

| Source prefix | Meaning |
|---|---|
| `dot_` | Maps to `.` (e.g. `dot_zshrc` → `~/.zshrc`) |
| `private_dot_` | Same but with mode 0600 |
| `run_onchange_before_` | Shell script run when its content changes, before applying |
| `modify_` | Script that receives the current target on stdin and outputs the desired content on stdout; use when only part of a file should be managed |
| `.tmpl` suffix | Go template file (uses chezmoi template data) |

## Repository Structure

### Zsh

- **`dot_zshrc`** — Zsh entry point. Responsible for setting environment variables, PATH extensions, and sourcing external tool initializations (cargo, nvm, fzf, starship, etc.). All modular configs are loaded from `~/.config/zsh/*.zsh`.
- **`dot_config/zsh/plugins.zsh`** — oh-my-zsh setup and plugin management. The place to add, remove, or configure oh-my-zsh plugins.
- **`dot_config/zsh/aliases.zsh`** — General-purpose shell aliases. Add any new aliases here.
- **`dot_config/zsh/moreh.zsh`** — Work-specific shell functions and aliases (Kubernetes, Helm, etc.). Anything job-specific that shouldn't live in general config goes here.

New `*.zsh` files dropped into `dot_config/zsh/` are automatically sourced by `dot_zshrc`.

### Prompt

- **`dot_config/starship.toml`** — Starship prompt appearance: color theme, per-module styles, prompt character. Dracula theme applied via `[palettes.dracula]`.

### Herdr

- **`dot_config/herdr/config.toml`** — All herdr configuration: prefix and keybindings, theme, tab bar entries, and notification delivery. Keybindings are ported from the tmux config this repo used previously, so `prefix` is `ctrl+a` and a few herdr defaults are moved aside to keep the tmux keys (`edit_scrollback` and `resize_mode` are shifted to their `shift` variants).

`config.toml` is the only herdr file this repo owns. The binary is installed by `run_onchange_before_03_install-binaries.sh`, and `run_onchange_after_20_herdr-setup.sh` installs the two things the config depends on: the Claude Code integration hook and the `chmarax.herdr-nvim` plugin that `prefix+e` and `prefix+o` are bound to. Neither of those is checked in, because herdr owns their contents — it rewrites the hook script on every integration version bump, and it unpacks plugins with absolute paths and a resolved commit baked in. Both checks are idempotent, so the script is safe to re-run.

After editing, apply it to the running server with `herdr server reload-config`. It reports parse errors, unknown keys, and invalid keybindings as diagnostics, and answers `applied`, `partial`, or `failed` — a silent `applied` with empty diagnostics is the only result that means every entry was accepted.

### Claude Code

- **`dot_claude/`** — Global Claude Code config: `settings.json` (permissions, hooks, env), `CLAUDE.md` (instructions for every project), and `output-styles/fluent-korean.md`.

Marketplaces and plugins are not checked in. `~/.claude/plugins` holds a few hundred megabytes of marketplace clones and plugin cache that are re-fetched from GitHub, and `installed_plugins.json` records absolute paths and commit SHAs that do not travel between machines. `run_onchange_after_21_claude-plugins.sh` declares the marketplaces and plugin ids instead and is idempotent, so adding a plugin means adding one line there. Plugins with scope `synced` come from claude.ai and are left to Claude Code; skills under `~/.claude/skills` are either symlinks into other checkouts or cloud-synced, so none of them are managed here either.

### Git

- **`dot_gitconfig.tmpl`** — Global git configuration. Uses `.email` and `.editor` template variables (set at `chezmoi init` time).

### Neovim

- **`dot_config/nvim/`** — LazyVim-based Neovim config. Custom plugins live in `lua/plugins/`.
- **`dot_config/nvim/modify_lazyvim.json`** — Modify script that syncs `extras` (enabled LazyVim modules) and `version` across machines while preserving the local `news` field, which is a per-environment value tracking which LazyVim changelog entries have been seen.

### Other Tools

- **`dot_config/lazygit/`** — Lazygit configuration.

### Chezmoi Internals

- **`.chezmoi.toml.tmpl`** — Chezmoi config template. Prompts for `email` on first `chezmoi init`. Sets `autoCommit = true` and `autoPush = true`, so every `chezmoi apply` commits and pushes automatically — be intentional about what files are added or modified.
- **`.chezmoiexternal.toml`** — External git repos managed by chezmoi (refreshed weekly): oh-my-zsh and oh-my-zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab). Add new external repos here.
- **`.chezmoiignore`** — Files in the source repo that should not be deployed to `$HOME`. Add source-only files (docs, scripts, etc.) here.

## Install Scripts (run in order on content change)

| Script | Purpose |
|---|---|
| `run_onchange_before_00_install-packages.sh` | OS package manager installs: poppler (`pdftoppm`); on macOS also GNU coreutils, so `ls` can alias to `gls` |
| `run_onchange_before_01_install-rust.sh` | Installs Rust toolchain via rustup |
| `run_onchange_before_02_install-zsh.sh` | Builds zsh from source to `~/.local` if not found |
| `run_onchange_before_03_install-binaries.sh` | Installs CLI tools to `~/.local/bin`: neovim (GitHub latest release), fzf (git clone), starship (official install.sh), herdr (official install.sh) |
| `run_onchange_before_04_install-cargo-packages.sh` | Installs cargo-based CLI tools: ripgrep, bat, git-delta |
| `run_onchange_after_20_herdr-setup.sh` | Installs the herdr Claude Code integration hook and the herdr-nvim plugin (runs after apply, so `config.toml` is already in place) |
| `run_onchange_after_21_claude-plugins.sh` | Adds the declared Claude Code marketplaces and installs the declared plugins |

All tools are installed to `~/.local/bin` without sudo. New tools that fit this pattern should be added to script `03` or `04` depending on whether they install via cargo.

## Template Variables

Defined in `.chezmoi.toml.tmpl`, available in any `.tmpl` file:
- `{{ .email }}` — Git commit email
- `{{ .editor }}` — Set to `"nvim"`
