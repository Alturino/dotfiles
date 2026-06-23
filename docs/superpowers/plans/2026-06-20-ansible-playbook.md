# Ansible Playbook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create Ansible playbooks to automate dev environment setup for Ubuntu/Debian and Fedora with tag-based selective installation.

**Architecture:** Separate playbooks per distro (ubuntu.yml, fedora.yml) with shared task files organized by category. Tags enable selective installation.

**Tech Stack:** Ansible, YAML

## Global Constraints

- Targets: Ubuntu/Debian and Fedora
- Ansible 2.9+ compatibility
- Idempotent tasks (safe to run multiple times)
- Use `creates` parameter for non-idempotent shell scripts
- Dotfiles sourced from `{{ playbook_dir }}/..`

---

## File Structure

```
ansible/
├── ubuntu.yml              # Main playbook for Ubuntu/Debian
├── fedora.yml              # Main playbook for Fedora
├── inventory.ini           # Localhost inventory
├── vars/
│   ├── common.yml          # Shared variables
│   ├── ubuntu.yml          # Ubuntu-specific vars
│   └── fedora.yml          # Fedora-specific vars
└── tasks/
    ├── apt_packages.yml    # System packages (apt)
    ├── dnf_packages.yml    # System packages (dnf)
    ├── ohmyzsh.yml         # Oh My Zsh installation
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
    ├── tools.yml           # Misc dev tools
    ├── dotfiles.yml        # Symlink dotfiles
    └── cleanup.yml         # Remove old packages
```

---

### Task 1: Create directory structure and inventory

**Files:**
- Create: `ansible/inventory.ini`

- [ ] **Step 1: Create ansible directory**

```bash
mkdir -p ansible/vars ansible/tasks
```

- [ ] **Step 2: Create inventory file**

```ini
# ansible/inventory.ini
[local]
localhost ansible_connection=local
```

- [ ] **Step 3: Commit**

```bash
git add ansible/
git commit -m "feat(ansible): create directory structure and inventory"
```

---

### Task 2: Create variables files

**Files:**
- Create: `ansible/vars/common.yml`
- Create: `ansible/vars/ubuntu.yml`
- Create: `ansible/vars/fedora.yml`

- [ ] **Step 1: Create common variables**

```yaml
# ansible/vars/common.yml
dotfiles_repo_path: "{{ playbook_dir }}/.."
user: "{{ ansible_user_id }}"

# Oh My Zsh
ohmyzsh_install_url: "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# fnm
fnm_install_url: "https://fnm.vercel.app/install"

# uv
uv_install_url: "https://astral.sh/uv/install.sh"

# starship
starship_install_url: "https://starship.rs/install.sh"

# bob (neovim)
bob_install_url: "https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh"
bob_version: "v0.12.3"

# SDKMAN
sdkman_install_url: "https://get.sdkman.io"

# GVM
gvm_install_url: "https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer"
go_version: "go1.26.4"

# Docker
docker_gpg_url: "https://download.docker.com/linux/ubuntu/gpg"
docker_repo_url: "https://download.docker.com/linux/ubuntu"

# Lazygit
lazygit_install_url: "https://raw.githubusercontent.com/jesseduffield/lazygit/master/install.sh"
```

- [ ] **Step 2: Create Ubuntu variables**

```yaml
# ansible/vars/ubuntu.yml
apt_packages:
  # Base
  - curl
  - unzip
  - git
  - zip
  - bison
  - xdg-utils
  - ca-certificates
  - gnupg
  - lsb-release
  - software-properties-common
  - apt-transport-https

  # Shells
  - zsh
  - fzf
  - zsh-syntax-highlighting

  # Dev tools
  - htop
  - ripgrep
  - bat
  - git-delta
  - eza
  - tmux

  # From deb_install.sh
  - ubuntu-restricted-extras
  - gnome-tweaks
  - vlc
  - python-is-python3
  - cmake
  - pkg-config
  - libfreetype6-dev
  - libfontconfig1-dev
  - libxcb-xfixes0-dev
  - libxkbcommon-dev
  - python3
  - texlive-full
  - android-tools-adb
  - cpp
  - gcc
  - g++-12
  - libqt5widgets5
  - libqt5network5
  - libqt5svg5
  - ruby-full
  - fish
  - iptables

  # Syncthing
  - syncthing

  # GitHub CLI
  - gh

docker_packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin
```

- [ ] **Step 3: Create Fedora variables**

```yaml
# ansible/vars/fedora.yml
dnf_packages:
  # Base
  - curl
  - unzip
  - git
  - zip
  - bison
  - xdg-utils
  - ca-certificates
  - gnupg2

  # Shells
  - zsh
  - fzf
  - zsh-syntax-highlighting

  # Dev tools
  - htop
  - ripgrep
  - bat
  - git-delta
  - eza
  - tmux

  # Dev
  - python3
  - python3-pip
  - cmake
  - pkg-config
  - gcc
  - gcc-c++
  - make

docker_packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin
```

- [ ] **Step 4: Commit**

```bash
git add ansible/vars/
git commit -m "feat(ansible): add variable files for common, ubuntu, fedora"
```

---

### Task 3: Create apt_packages.yml task

**Files:**
- Create: `ansible/tasks/apt_packages.yml`

- [ ] **Step 1: Create apt packages task**

```yaml
# ansible/tasks/apt_packages.yml
---
- name: Update apt cache
  ansible.builtin.apt:
    update_cache: yes
    cache_valid_time: 3600
  become: yes
  tags: always

- name: Install apt packages
  ansible.builtin.apt:
    name: "{{ apt_packages }}"
    state: present
  become: yes
  tags: always

- name: Install Docker apt repository GPG key
  ansible.builtin.apt_key:
    url: "{{ docker_gpg_url }}"
    state: present
  become: yes
  tags: docker

- name: Add Docker apt repository
  ansible.builtin.apt_repository:
    repo: "deb [arch={{ ansible_architecture | replace('x86_64', 'amd64') | replace('aarch64', 'arm64') }} signed-by=/usr/share/keyrings/docker.asc] {{ docker_repo_url }} {{ ansible_distribution_release }} stable"
    state: present
  become: yes
  tags: docker

- name: Install Docker packages
  ansible.builtin.apt:
    name: "{{ docker_packages }}"
    state: present
    update_cache: yes
  become: yes
  tags: docker
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/apt_packages.yml
git commit -m "feat(ansible): add apt packages task"
```

---

### Task 4: Create dnf_packages.yml task

**Files:**
- Create: `ansible/tasks/dnf_packages.yml`

- [ ] **Step 1: Create dnf packages task**

```yaml
# ansible/tasks/dnf_packages.yml
---
- name: Update dnf cache
  ansible.builtin.dnf:
    update_cache: yes
  become: yes
  tags: always

- name: Install dnf packages
  ansible.builtin.dnf:
    name: "{{ dnf_packages }}"
    state: present
  become: yes
  tags: always

- name: Add Docker CE repository
  ansible.builtin.shell: |
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  args:
    creates: /etc/yum.repos.d/docker-ce.repo
  become: yes
  tags: docker

- name: Install Docker packages
  ansible.builtin.dnf:
    name: "{{ docker_packages }}"
    state: present
  become: yes
  tags: docker
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/dnf_packages.yml
git commit -m "feat(ansible): add dnf packages task"
```

---

### Task 5: Create locale.yml task

**Files:**
- Create: `ansible/tasks/locale.yml`

- [ ] **Step 1: Create locale task**

```yaml
# ansible/tasks/locale.yml
---
- name: Install locale package (Ubuntu/Debian)
  ansible.builtin.apt:
    name: locales
    state: present
  become: yes
  when: ansible_os_family == "Debian"
  tags: locale

- name: Generate en_US.UTF-8 locale (Ubuntu/Debian)
  community.general.locale_gen:
    name: en_US.UTF-8
    state: present
  become: yes
  when: ansible_os_family == "Debian"
  tags: locale

- name: Set default locale (Ubuntu/Debian)
  ansible.builtin.lineinfile:
    path: /etc/default/locale
    regexp: '^LANG='
    line: 'LANG=en_US.UTF-8'
  become: yes
  when: ansible_os_family == "Debian"
  tags: locale

- name: Install glibc-langpack-en (Fedora)
  ansible.builtin.dnf:
    name: glibc-langpack-en
    state: present
  become: yes
  when: ansible_os_family == "RedHat"
  tags: locale

- name: Set default locale (Fedora)
  ansible.builtin.lineinfile:
    path: /etc/locale.conf
    regexp: '^LANG='
    line: 'LANG=en_US.UTF-8'
  become: yes
  when: ansible_os_family == "RedHat"
  tags: locale
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/locale.yml
git commit -m "feat(ansible): add locale configuration task"
```

---

### Task 6: Create ohmyzsh.yml task

**Files:**
- Create: `ansible/tasks/ohmyzsh.yml`

- [ ] **Step 1: Create Oh My Zsh task**

```yaml
# ansible/tasks/ohmyzsh.yml
---
- name: Check if Oh My Zsh is installed
  ansible.builtin.stat:
    path: "{{ home }}/.oh-my-zsh"
  register: ohmyzsh_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: shells

- name: Install Oh My Zsh
  ansible.builtin.shell: |
    sh -c "$(curl -fsSL {{ ohmyzsh_install_url }})" "" --unattended --keep-zshrc
  when: not ohmyzsh_installed.stat.exists
  tags: shells
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/ohmyzsh.yml
git commit -m "feat(ansible): add Oh My Zsh installation task"
```

---

### Task 7: Create fnm.yml task

**Files:**
- Create: `ansible/tasks/fnm.yml`

- [ ] **Step 1: Create fnm task**

```yaml
# ansible/tasks/fnm.yml
---
- name: Check if fnm is installed
  ansible.builtin.stat:
    path: "{{ home }}/.local/share/fnm/fnm"
  register: fnm_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install fnm
  ansible.builtin.shell: |
    curl -fsSL {{ fnm_install_url }} | bash
  when: not fnm_installed.stat.exists
  tags: dev-tools

- name: Install Node.js LTS via fnm
  ansible.builtin.shell: |
    export PATH="{{ home }}/.local/share/fnm:$PATH"
    eval "$(fnm env)"
    fnm install --lts
    fnm use lts-latest
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/fnm.yml
git commit -m "feat(ansible): add fnm installation task"
```

---

### Task 8: Create uv.yml task

**Files:**
- Create: `ansible/tasks/uv.yml`

- [ ] **Step 1: Create uv task**

```yaml
# ansible/tasks/uv.yml
---
- name: Check if uv is installed
  ansible.builtin.stat:
    path: "{{ home }}/.local/bin/uv"
  register: uv_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install uv
  ansible.builtin.shell: |
    curl -LsSf {{ uv_install_url }} | sh
  when: not uv_installed.stat.exists
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/uv.yml
git commit -m "feat(ansible): add uv installation task"
```

---

### Task 9: Create starship.yml task

**Files:**
- Create: `ansible/tasks/starship.yml`

- [ ] **Step 1: Create starship task**

```yaml
# ansible/tasks/starship.yml
---
- name: Check if starship is installed
  ansible.builtin.stat:
    path: "{{ home }}/.local/bin/starship"
  register: starship_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install starship
  ansible.builtin.shell: |
    curl -sS {{ starship_install_url }} | sh -s -- --yes
  when: not starship_installed.stat.exists
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/starship.yml
git commit -m "feat(ansible): add starship installation task"
```

---

### Task 10: Create zoxide.yml task

**Files:**
- Create: `ansible/tasks/zoxide.yml`

- [ ] **Step 1: Create zoxide task**

```yaml
# ansible/tasks/zoxide.yml
---
- name: Check if zoxide is installed
  ansible.builtin.stat:
    path: "{{ home }}/.local/bin/zoxide"
  register: zoxide_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install zoxide
  ansible.builtin.shell: |
    curl -sS {{ zoxide_install_url }} | bash
  when: not zoxide_installed.stat.exists
  environment:
    ZOXID_INSTALL_NO_MODIFY_RC: "1"
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/zoxide.yml
git commit -m "feat(ansible): add zoxide installation task"
```

---

### Task 11: Create tmux.yml task

**Files:**
- Create: `ansible/tasks/tmux.yml`

- [ ] **Step 1: Create tmux task**

```yaml
# ansible/tasks/tmux.yml
---
- name: Check if TPM is installed
  ansible.builtin.stat:
    path: "{{ home }}/.tmux/plugins/tpm"
  register: tpm_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: tmux

- name: Clone TPM
  ansible.builtin.git:
    repo: https://github.com/tmux-plugins/tpm
    dest: "{{ home }}/.tmux/plugins/tpm"
    version: master
  when: not tpm_installed.stat.exists
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: tmux
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/tmux.yml
git commit -m "feat(ansible): add tmux and TPM task"
```

---

### Task 12: Create bob.yml task

**Files:**
- Create: `ansible/tasks/bob.yml`

- [ ] **Step 1: Create bob task**

```yaml
# ansible/tasks/bob.yml
---
- name: Check if bob is installed
  ansible.builtin.stat:
    path: "{{ home }}/.local/bin/bob"
  register: bob_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: editors

- name: Install bob
  ansible.builtin.shell: |
    curl -sS {{ bob_install_url }} | bash
  when: not bob_installed.stat.exists
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: editors

- name: Install Neovim {{ bob_version }} via bob
  ansible.builtin.shell: |
    export PATH="{{ home }}/.local/bin:$PATH"
    bob install {{ bob_version }}
    bob use {{ bob_version }}
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  when: not bob_installed.stat.exists
  tags: editors
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/bob.yml
git commit -m "feat(ansible): add bob and neovim installation task"
```

---

### Task 13: Create sdkman.yml task

**Files:**
- Create: `ansible/tasks/sdkman.yml`

- [ ] **Step 1: Create SDKMAN task**

```yaml
# ansible/tasks/sdkman.yml
---
- name: Check if SDKMAN is installed
  ansible.builtin.stat:
    path: "{{ home }}/.sdkman/bin/sdkman-init.sh"
  register: sdkman_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install SDKMAN
  ansible.builtin.shell: |
    curl -s "{{ sdkman_install_url }}" | bash
  when: not sdkman_installed.stat.exists
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install Java via SDKMAN
  ansible.builtin.shell: |
    source {{ home }}/.sdkman/bin/sdkman-init.sh
    sdk install java 26.0.1-tem
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  when: not sdkman_installed.stat.exists
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/sdkman.yml
git commit -m "feat(ansible): add SDKMAN installation task"
```

---

### Task 14: Create gvm.yml task

**Files:**
- Create: `ansible/tasks/gvm.yml`

- [ ] **Step 1: Create GVM task**

```yaml
# ansible/tasks/gvm.yml
---
- name: Check if GVM is installed
  ansible.builtin.stat:
    path: "{{ home }}/.gvm/scripts/gvm"
  register: gvm_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install GVM
  ansible.builtin.shell: |
    bash < <(curl -s -S -L {{ gvm_install_url }})
  when: not gvm_installed.stat.exists
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install Go {{ go_version }} via GVM
  ansible.builtin.shell: |
    source {{ home }}/.gvm/scripts/gvm
    gvm install {{ go_version }} -B
    gvm use --default {{ go_version }}
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  when: not gvm_installed.stat.exists
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/gvm.yml
git commit -m "feat(ansible): add GVM and Go installation task"
```

---

### Task 15: Create docker.yml task

**Files:**
- Create: `ansible/tasks/docker.yml`

- [ ] **Step 1: Create Docker task**

```yaml
# ansible/tasks/docker.yml
---
- name: Add current user to docker group
  ansible.builtin.user:
    name: "{{ user }}"
    groups: docker
    append: yes
  become: yes
  tags: docker

- name: Start Docker service
  ansible.builtin.service:
    name: docker
    state: started
    enabled: yes
  become: yes
  tags: docker

- name: Verify Docker installation
  ansible.builtin.command: docker run hello-world
  register: docker_test
  changed_when: false
  tags: docker

- name: Display Docker test output
  ansible.builtin.debug:
    var: docker_test.stdout_lines
  tags: docker
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/docker.yml
git commit -m "feat(ansible): add Docker setup task"
```

---

### Task 16: Create tools.yml task

**Files:**
- Create: `ansible/tasks/tools.yml`

- [ ] **Step 1: Create tools task**

```yaml
# ansible/tasks/tools.yml
---
- name: Check if lazygit is installed
  ansible.builtin.stat:
    path: "{{ home }}/.local/bin/lazygit"
  register: lazygit_installed
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Install lazygit
  ansible.builtin.shell: |
    curl -s {{ lazygit_install_url }} | bash
  when: not lazygit_installed.stat.exists
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dev-tools

- name: Build bat cache
  ansible.builtin.command: bat cache --build
  become: yes
  changed_when: false
  tags: dev-tools

- name: Install opencode-ai globally
  community.general.npm:
    name: opencode-ai
    global: yes
    state: present
  become: yes
  tags: dev-tools
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/tools.yml
git commit -m "feat(ansible): add misc dev tools task"
```

---

### Task 17: Create cleanup.yml task

**Files:**
- Create: `ansible/tasks/cleanup.yml`

- [ ] **Step 1: Create cleanup task**

```yaml
# ansible/tasks/cleanup.yml
---
- name: Remove old Docker packages (Ubuntu/Debian)
  ansible.builtin.apt:
    name:
      - docker.io
      - docker-compose
      - docker-compose-v2
      - docker-doc
      - podman-docker
      - containerd
      - runc
    state: absent
  become: yes
  when: ansible_os_family == "Debian"
  ignore_errors: yes
  tags: docker

- name: Purge old Docker CE packages (Ubuntu/Debian)
  ansible.builtin.apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
      - docker-ce-rootless-extras
    state: absent
    purge: yes
  become: yes
  when: ansible_os_family == "Debian"
  ignore_errors: yes
  tags: docker
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/cleanup.yml
git commit -m "feat(ansible): add cleanup task for old Docker packages"
```

---

### Task 18: Create dotfiles.yml task

**Files:**
- Create: `ansible/tasks/dotfiles.yml`

- [ ] **Step 1: Create dotfiles task**

```yaml
# ansible/tasks/dotfiles.yml
---
- name: Create symlink for .zshrc
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/zsh/.zshrc"
    dest: "{{ home }}/.zshrc"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- [ ] **Step 2: Create symlink for .tmux.conf**

```yaml
- name: Create symlink for .tmux.conf
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/tmux/.tmux.conf"
    dest: "{{ home }}/.tmux.conf"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles
```

- [ ] **Step 3: Create symlink for starship config**

```yaml
- name: Create directory for starship config
  ansible.builtin.file:
    path: "{{ home }}/.config"
    state: directory
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for starship.toml
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/starship/starship.toml"
    dest: "{{ home }}/.config/starship.toml"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles
```

- [ ] **Step 4: Create symlink for bat config**

```yaml
- name: Create directory for bat config
  ansible.builtin.file:
    path: "{{ home }}/.config/bat"
    state: directory
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for bat config
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/bat/"
    dest: "{{ home }}/.config/bat"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles
```

- [ ] **Step 5: Create symlink for delta config**

```yaml
- name: Create symlink for git-delta config
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/delta/.gitconfig"
    dest: "{{ home }}/.gitconfig"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles
```

- [ ] **Step 6: Create symlink for lazygit config**

```yaml
- name: Create directory for lazygit config
  ansible.builtin.file:
    path: "{{ home }}/.config/lazygit"
    state: directory
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for lazygit config
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/lazygit/"
    dest: "{{ home }}/.config/lazygit"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles
```

- [ ] **Step 7: Commit**

```bash
git add ansible/tasks/dotfiles.yml
git commit -m "feat(ansible): add dotfiles symlinking task"
```

---

### Task 19: Create ubuntu.yml playbook

**Files:**
- Create: `ansible/ubuntu.yml`

- [ ] **Step 1: Create Ubuntu playbook**

```yaml
# ansible/ubuntu.yml
---
- name: Dev environment setup for Ubuntu/Debian
  hosts: local
  connection: local
  become: no

  vars_files:
    - vars/common.yml
    - vars/ubuntu.yml

  tasks:
    - name: Import apt packages
      ansible.builtin.import_tasks: tasks/apt_packages.yml
      tags: always

    - name: Import locale
      ansible.builtin.import_tasks: tasks/locale.yml
      tags: locale

    - name: Import Oh My Zsh
      ansible.builtin.import_tasks: tasks/ohmyzsh.yml
      tags: shells

    - name: Import fnm
      ansible.builtin.import_tasks: tasks/fnm.yml
      tags: dev-tools

    - name: Import uv
      ansible.builtin.import_tasks: tasks/uv.yml
      tags: dev-tools

    - name: Import starship
      ansible.builtin.import_tasks: tasks/starship.yml
      tags: dev-tools

    - name: Import zoxide
      ansible.builtin.import_tasks: tasks/zoxide.yml
      tags: dev-tools

    - name: Import tmux
      ansible.builtin.import_tasks: tasks/tmux.yml
      tags: tmux

    - name: Import bob
      ansible.builtin.import_tasks: tasks/bob.yml
      tags: editors

    - name: Import SDKMAN
      ansible.builtin.import_tasks: tasks/sdkman.yml
      tags: dev-tools

    - name: Import GVM
      ansible.builtin.import_tasks: tasks/gvm.yml
      tags: dev-tools

    - name: Import Docker
      ansible.builtin.import_tasks: tasks/docker.yml
      tags: docker

    - name: Import tools
      ansible.builtin.import_tasks: tasks/tools.yml
      tags: dev-tools

    - name: Import dotfiles
      ansible.builtin.import_tasks: tasks/dotfiles.yml
      tags: dotfiles

    - name: Import cleanup
      ansible.builtin.import_tasks: tasks/cleanup.yml
      tags: docker
```

- [ ] **Step 2: Commit**

```bash
git add ansible/ubuntu.yml
git commit -m "feat(ansible): add Ubuntu playbook"
```

---

### Task 20: Create fedora.yml playbook

**Files:**
- Create: `ansible/fedora.yml`

- [ ] **Step 1: Create Fedora playbook**

```yaml
# ansible/fedora.yml
---
- name: Dev environment setup for Fedora
  hosts: local
  connection: local
  become: no

  vars_files:
    - vars/common.yml
    - vars/fedora.yml

  tasks:
    - name: Import dnf packages
      ansible.builtin.import_tasks: tasks/dnf_packages.yml
      tags: always

    - name: Import locale
      ansible.builtin.import_tasks: tasks/locale.yml
      tags: locale

    - name: Import Oh My Zsh
      ansible.builtin.import_tasks: tasks/ohmyzsh.yml
      tags: shells

    - name: Import fnm
      ansible.builtin.import_tasks: tasks/fnm.yml
      tags: dev-tools

    - name: Import uv
      ansible.builtin.import_tasks: tasks/uv.yml
      tags: dev-tools

    - name: Import starship
      ansible.builtin.import_tasks: tasks/starship.yml
      tags: dev-tools

    - name: Import zoxide
      ansible.builtin.import_tasks: tasks/zoxide.yml
      tags: dev-tools

    - name: Import tmux
      ansible.builtin.import_tasks: tasks/tmux.yml
      tags: tmux

    - name: Import bob
      ansible.builtin.import_tasks: tasks/bob.yml
      tags: editors

    - name: Import SDKMAN
      ansible.builtin.import_tasks: tasks/sdkman.yml
      tags: dev-tools

    - name: Import GVM
      ansible.builtin.import_tasks: tasks/gvm.yml
      tags: dev-tools

    - name: Import Docker
      ansible.builtin.import_tasks: tasks/docker.yml
      tags: docker

    - name: Import tools
      ansible.builtin.import_tasks: tasks/tools.yml
      tags: dev-tools

    - name: Import dotfiles
      ansible.builtin.import_tasks: tasks/dotfiles.yml
      tags: dotfiles
```

- [ ] **Step 2: Commit**

```bash
git add ansible/fedora.yml
git commit -m "feat(ansible): add Fedora playbook"
```

---

### Task 21: Fix dotfiles.yml structure

**Files:**
- Modify: `ansible/tasks/dotfiles.yml`

- [ ] **Step 1: Fix dotfiles.yml**

The dotfiles.yml task was written with multiple step comments that broke YAML structure. Here's the corrected version:

```yaml
# ansible/tasks/dotfiles.yml
---
- name: Create symlink for .zshrc
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/zsh/.zshrc"
    dest: "{{ home }}/.zshrc"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for .tmux.conf
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/tmux/.tmux.conf"
    dest: "{{ home }}/.tmux.conf"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create directory for starship config
  ansible.builtin.file:
    path: "{{ home }}/.config"
    state: directory
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for starship.toml
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/starship/starship.toml"
    dest: "{{ home }}/.config/starship.toml"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create directory for bat config
  ansible.builtin.file:
    path: "{{ home }}/.config/bat"
    state: directory
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for bat config
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/bat/"
    dest: "{{ home }}/.config/bat"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for git-delta config
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/delta/.gitconfig"
    dest: "{{ home }}/.gitconfig"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create directory for lazygit config
  ansible.builtin.file:
    path: "{{ home }}/.config/lazygit"
    state: directory
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles

- name: Create symlink for lazygit config
  ansible.builtin.file:
    src: "{{ dotfiles_repo_path }}/lazygit/"
    dest: "{{ home }}/.config/lazygit"
    state: link
    force: yes
  vars:
    home: "{{ lookup('env', 'HOME') }}"
  tags: dotfiles
```

- [ ] **Step 2: Commit**

```bash
git add ansible/tasks/dotfiles.yml
git commit -m "fix(ansible): correct dotfiles.yml YAML structure"
```

---

### Task 22: Validate YAML syntax

**Files:**
- Validate: all `ansible/**/*.yml` files

- [ ] **Step 1: Install ansible-lint (optional)**

```bash
pip install ansible-lint
```

- [ ] **Step 2: Validate YAML syntax**

```bash
cd ansible && yamllint *.yml vars/*.yml tasks/*.yml
```

- [ ] **Step 3: Run ansible-playbook --syntax-check**

```bash
cd ansible && ansible-playbook ubuntu.yml --syntax-check
cd ansible && ansible-playbook fedora.yml --syntax-check
```

- [ ] **Step 4: Commit any fixes**

```bash
git add ansible/
git commit -m "fix(ansible): YAML syntax fixes"
```

---

### Task 23: Update existing deb_install.sh

**Files:**
- Modify: `installation_script/deb_install.sh`

- [ ] **Step 1: Add reference to Ansible playbook**

```bash
#!/bin/bash
# NOTE: This script is superseded by ansible/ubuntu.yml
# For new installations, use: cd ansible && ansible-playbook ubuntu.yml -i inventory.ini
# This script is kept for reference only.
```

- [ ] **Step 2: Commit**

```bash
git add installation_script/deb_install.sh
git commit -m "docs: deprecate deb_install.sh in favor of ansible playbook"
```

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-20-ansible-playbook.md`.

**Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
