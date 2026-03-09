# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [chezmoi](https://www.chezmoi.io/) dotfiles repository. Chezmoi manages dotfiles across machines by maintaining a source directory (`~/.local/share/chezmoi`) that maps to actual home directory files.

## chezmoi commands

```sh
chezmoi apply          # apply changes from source to home directory
chezmoi diff           # show what apply would change
chezmoi add <file>     # track a new dotfile
chezmoi edit <file>    # edit a tracked dotfile (opens source file)
chezmoi re-add         # update source from home directory if you edited files directly
chezmoi data           # show template data (e.g., .email, .editor values)
```

## File naming conventions

chezmoi uses filename prefixes/suffixes that encode metadata:

| Prefix/Suffix | Meaning |
|---|---|
| `dot_` | maps to `.` in home dir (e.g., `dot_gitconfig` → `~/.gitconfig`) |
| `private_` | file permissions 0600 |
| `run_onchange_before_` | script run before apply when file content changes |
| `.tmpl` suffix | Go template file; uses `{{ .variable }}` syntax |

## Repository structure

- `dot_gitconfig.tmpl` — Git config using chezmoi templates for `.email` and `.editor` variables
- `dot_config/private_fish/` — Fish shell config (config.fish, conf.d/, fish_plugins)
- `dot_config/nvim/` — Neovim config (LazyVim-based)
- `dot_config/lazygit/config.yml` — Lazygit with Dracula theme
- `dot_cargo/` — Cargo/Rust toolchain config
- `dot_tmux*` — Tmux config
- `private_dot_profile` — Login shell profile (switches to fish unless `$CLAUDECODE` is set)
- `run_onchange_before_install-packages.sh` — Package installation script

## Neovim setup

LazyVim with extras enabled in `dot_config/nvim/lazyvim.json`:
- `ai.claudecode` — Claude Code integration (`<leader>a` prefix for all Claude keymaps)
- `editor.fzf`, `editor.mini-diff`, `editor.mini-files`, `editor.mini-move`
- `lang.clangd`, `lang.python`, `lang.rust`
- `util.chezmoi` — chezmoi source file detection

Custom plugins in `dot_config/nvim/lua/plugins/`:
- `ai.lua` — claudecode.nvim keymaps (forced `SHELL=/bin/bash` for terminal)
- `animate.lua` — disables snacks.nvim scroll animation

## Fish shell setup

Fish plugins managed via fisher (`dot_config/private_fish/fish_plugins`):
- `dracula/fish` + `vitallium/tokyonight-fish` — themes (Dracula active)
- `patrickf1/fzf.fish` — fzf keybindings
- `ilancosman/tide@v6` — prompt
- `jorgebucaran/nvm.fish` — Node version manager

Key config in `conf.d/moreh.fish`: Kubernetes/Helm workflow abbreviations and functions targeting the `moreh` Helm repo and a local kubeconfig at `~/mif/kubeconfig.yaml`.

## Template variables

chezmoi data variables used in templates (set via `chezmoi init` or `~/.config/chezmoi/chezmoi.toml`):
- `.email` — Git commit email
- `.editor` — Default editor (set to `nvim`)
