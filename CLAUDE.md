# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A [chezmoi](https://chezmoi.io) dotfiles repository. Chezmoi manages dotfiles by mapping source files to target locations in `$HOME`. Changes here are applied by running `chezmoi apply`.

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
| `.tmpl` suffix | Go template file (uses chezmoi template data) |

## Repository Structure

- **`dot_zshrc`** — Minimal zshrc: sets env vars, sources cargo, nvm, then loads all files from `~/.config/zsh/conf.d/*.zsh`
- **`dot_config/zsh/conf.d/`** — Zsh configuration fragments loaded by `.zshrc`:
  - `plugins.zsh` — oh-my-zsh setup with Dracula theme; plugins: git, fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting
  - `aliases.zsh` — `vi=nvim` alias
  - `moreh.zsh` — Kubernetes/Helm helper functions for work (kubectl aliases, `helm_install`/`helm_uninstall`/`helm_reinstall`)
- **`dot_gitconfig.tmpl`** — Git config template; uses `.email` and `.editor` template variables; conditionally sets `conflictstyle` based on git version
- **`dot_tmux.conf`** — Tmux config: prefix `C-a`, vi bindings, TPM plugins (resurrect, continuum, Dracula theme)
- **`dot_config/nvim/`** — LazyVim-based Neovim config with custom plugins in `lua/plugins/`
- **`dot_config/lazygit/`** — Lazygit configuration
- **`.chezmoi.toml.tmpl`** — Chezmoi config template; prompts for `email` once; enables `autoCommit` and `autoPush` (changes are committed and pushed automatically on `chezmoi apply`)
- **`.chezmoiexternal.toml`** — External git repos managed by chezmoi: oh-my-zsh, Dracula theme, zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab (refreshed weekly)
- **`.chezmoiignore`** — Excludes README.md, tmux resurrect sessions, fish variables, swap files

## Install Scripts (run in order on content change)

| Script | Purpose |
|---|---|
| `run_onchange_before_00_install-packages.sh` | (empty placeholder) |
| `run_onchange_before_01_install-rust.sh` | Installs Rust via rustup if cargo not found |
| `run_onchange_before_02_install-zsh.sh` | Builds zsh 5.9 from source to `~/.local` if not found |
| `run_onchange_before_03_install-binaries.sh` | Downloads neovim 0.10.4 and fzf 0.57.0 binaries to `~/.local` |
| `run_onchange_before_04_install-cargo-packages.sh` | Installs ripgrep, bat, git-delta via cargo |

## Template Data

Defined in `.chezmoi.toml.tmpl` and used in `.tmpl` files:
- `{{ .email }}` — Git commit email (prompted on first `chezmoi init`)
- `{{ .editor }}` — Set to `"nvim"`

## Auto-commit Behavior

`autoCommit = true` and `autoPush = true` are set in `.chezmoi.toml.tmpl`. Every `chezmoi apply` automatically commits and pushes changes to this repo. Be intentional about what files are added/modified.
