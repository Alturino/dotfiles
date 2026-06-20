# Ansible Playbook Design

## Overview

Create an Ansible playbook to automate installation of dev environment dependencies and dotfiles. Targets Ubuntu/Debian and Fedora with separate playbooks and shared task files. Uses tags for selective installation.

## Goals

- Automate installation of all tools from zsh history and existing deb_install.sh
- Support Ubuntu/Debian and Fedora
- Idempotent (safe to run multiple times)
- Tag-based selective installation
- Symlink dotfiles from this repo

## Directory Structure

```
ansible/
├── ubuntu.yml          # Main playbook for Ubuntu/Debian
├── fedora.yml          # Main playbook for Fedora
├── inventory.ini       # Localhost inventory
├── vars/
│   ├── common.yml      # Shared variables
│   ├── ubuntu.yml      # Ubuntu-specific vars
│   └── fedora.yml      # Fedora-specific vars
└── tasks/
    ├── apt_packages.yml    # System packages (apt)
    ├── dnf_packages.yml    # System packages (dnf)
    ├── ohmyzsh.yml         # Oh My Zsh
    ├── fnm.yml             # Fast Node Manager
    ├── uv.yml              # Python package manager
    ├── starship.yml        # Starship prompt
    ├── zoxide.yml          # Zoxide
    ├── tmux.yml            # Tmux + TPM
    ├── locale.yml          # Locale setup
    ├── bob.yml             # Neovim version manager
    ├── sdkman.yml          # SDKMAN
    ├── gvm.yml             # Go Version Manager
    ├── docker.yml          # Docker + Docker Compose
    ├── tools.yml           # Git-delta, htop, ripgrep, bat, lazygit, etc.
    ├── dotfiles.yml        # Symlink dotfiles to $HOME
    └── cleanup.yml         # Remove old Docker packages
```

## Tags

| Tag | Contents |
|-----|----------|
| `shells` | zsh, oh-my-zsh, fzf, zsh-syntax-highlighting |
| `editors` | bob (neovim version manager) |
| `dev-tools` | fnm, uv, starship, zoxide, sdkman, gvm, go, lazygit, git-delta, htop, ripgrep, bat, ripgrep |
| `docker` | docker-ce, docker-compose-plugin, docker-buildx-plugin, cleanup old packages |
| `tmux` | tmux, tpm |
| `gui-apps` | VS Code, VLC, GNOME tweaks, etc. |
| `dotfiles` | Symlink dotfiles to $HOME |
| `locale` | Locale setup (en_US.UTF-8) |

## Tools to Install

### From zsh history
- curl, unzip, git, zip, bison
- zsh + Oh My Zsh
- fzf, eza, zoxide
- fnm (Fast Node Manager) + Node LTS
- uv (Python package manager)
- starship (prompt)
- tmux + tpm
- bob (Neovim version manager) + v0.12.3
- SDKMAN + Java 26.0.1-tem
- GVM + Go 1.26.4
- lazygit
- git-delta, htop, ripgrep, bat
- Docker CE + Docker Compose
- opencode-ai (npm global)

### From deb_install.sh
- Ubuntu restricted extras, GNOME tweaks, VLC
- python-is-python3, cmake, pkg-config
- texlive-full, android-tools-adb
- cpp, gcc, g++-12
- Qt5 libraries
- zsh-syntax-highlighting, ruby-full
- Syncthing, Cloudflare Warp, GitHub CLI
- Fish shell, tmux
- VS Code

## Idempotency Strategy

- Use `ansible.builtin.apt` / `ansible.builtin.dnf` for package management (idempotent by default)
- Use `creates` parameter for shell script installs (Oh My Zsh, fnm, bob, etc.)
- Use `file` module with `state: link` for dotfiles
- Use `creates` or `when` conditions to skip already-completed tasks

## Variables

### common.yml
```yaml
dotfiles_repo_path: "{{ playbook_dir }}/.."
user: "{{ ansible_user_id }}"
```

### ubuntu.yml
```yaml
apt_packages:
  - curl
  - unzip
  - git
  - zsh
  - fzf
  - eza
  - zip
  - bison
  - htop
  - ripgrep
  - bat
  - git-delta
  - xdg-utils
  - language-pack-en
  - iptables
  # From deb_install.sh
  - ubuntu-restricted-extras
  - gnome-tweaks
  - vlc
  - python-is-python3
  - cmake
  - pkg-config
  - texlive-full
  - android-tools-adb
  - cpp
  - gcc
  - g++-12
  - libqt5widgets5
  - libqt5network5
  - libqt5svg5
  - zsh-syntaxh-highlighting
  - ruby-full
  - syncthing
  - fish
  - tmux
```

## Execution Flow

1. Update package cache
2. Install system packages
3. Configure locale
4. Install shells + Oh My Zsh
5. Install dev tools (fnm, uv, starship, zoxide, sdkman, gvm, go, lazygit, etc.)
6. Install Tmux + TPM
7. Install Docker (with cleanup of old packages)
8. Install GUI apps (VS Code, etc.)
9. Symlink dotfiles

## Usage

```bash
# Install everything on Ubuntu
ansible-playbook ubuntu.yml -i inventory.ini --tags "all"

# Install only Docker on Fedora
ansible-playbook fedora.yml -i inventory.ini --tags "docker"

# Install shells + dev tools
ansible-playbook ubuntu.yml -i inventory.ini --tags "shells,dev-tools"
```
