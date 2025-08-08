# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). The repository contains configuration files for a comprehensive Linux/macOS development environment including terminal, editor, window manager, and development tools.

## Key Commands

### chezmoi Commands
- `chezmoi apply` - Apply dotfiles to the system
- `chezmoi edit <file>` - Edit a template file
- `chezmoi add <file>` - Add a new file to be managed by chezmoi
- `chezmoi diff` - Show differences between managed files and target state
- `chezmoi status` - Show status of files

### System Setup
- Initial setup: `sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply rivernate`
- Package installation (Arch Linux): Run `run_once_install-packages.sh.tmpl` template
- Package installation (macOS): Run `run_once_brew_bundle.sh.tmpl` template

## Architecture

### Template System
All configuration files use chezmoi's Go template system:
- `.tmpl` files are Go templates that generate the actual config files
- Templates use variables like `{{ .chezmoi.os }}` for cross-platform compatibility
- Conditional blocks handle different operating systems and configurations

### Key Configuration Areas
- **Shell**: Zsh with Powerlevel10k theme (`dot_zshrc.tmpl`, `dot_p10k.zsh`)
- **Editor**: Neovim with Lua configuration (`dot_config/nvim/`)
- **Terminal**: Multiple terminal emulators (Alacritty, Kitty, WezTerm)
- **Development**: mise for language version management (`dot_config/mise/config.toml`)
- **Window Managers**: Support for bspwm, yabai, and Hyprland
- **Git**: Templated git configuration (`dot_gitconfig.tmpl`)

### Development Tools
- Languages managed by mise: Node.js, Go, Python, Java, Lua, PHP, Perl, OCaml, Julia, Deno
- Package managers: yay (Arch), brew (macOS), pnpm, yarn
- Development utilities: ripgrep, bat, exa, direnv, neovim

### Cross-Platform Support
The dotfiles support both Linux (primarily Arch Linux) and macOS with conditional templating based on `{{ .chezmoi.os }}` and `{{ .chezmoi.osRelease.id }}`.