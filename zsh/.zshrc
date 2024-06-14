# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOQUIT=false
ZSH_TMUX_FIXTERM=false

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
if [ ! -d "$ZSH/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/plugins/zsh-syntax-highlighting
fi
if [ ! -d "$ZSH/plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab.git $ZSH/plugins/fzf-tab
fi
if [ ! -d "$ZSH/plugins/fzf-tab-source" ]; then
  git clone https://github.com/Freed-Wu/fzf-tab-source.git $ZSH/plugins/fzf-tab-source
fi
if [ ! -d "$ZSH/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/plugins/zsh-autosuggestions
fi
plugins=(
  adb
  ansible
  bun
  catimg
  deno
  dnf
  docker
  docker-compose
  dotenv
  fd
  flutter
  fnm
  fzf
  fzf-tab
  fzf-tab-source
  gh
  git
  git-commit
  golang
  gpg-agent
  gradle
  helm
  kubectl
  minikube
  ng
  node
  npm
  nvm
  pip
  pod
  podman
  postgres
  python
  redis-cli
  ripgrep
  rvm
  spring
  systemd
  terraform
  tmux
  yarn
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Aliases
alias eza='eza '\''--icons'\'' '\''--git'\'''
alias la='eza -a'
alias ll='eza -l'
alias lla='eza -la'
alias ls='eza'
alias lt='eza --tree'

HISTSIZE="100000000000"
SAVEHIST="100000000000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt autocd

eval "$(zoxide init zsh)"

# Path
# export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
# export PATH=$PATH:"$GEM_HOME/bin"
export GOROOT=/usr/local/go
export GRAPHVIZ_DOT=/usr/bin/dot
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
export PATH="$PATH:$GRAPHVIZ_DOT"
export PATH="$PATH:$HOME/.cargo/env"
export PATH="$PATH:$HOME/.maestro/bin"
export PATH="$PATH:$HOME/Android/Sdk/platform-tools"
export PATH="$PATH:$HOME/go/bin/"
export PATH="$PATH:/usr/local/go/bin/"
export TERM="xterm-256color"

source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# fnm
FNM_PATH="/home/rickyalturino/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/rickyalturino/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

[[ -s "/home/rickyalturino/.gvm/scripts/gvm" ]] && source "/home/rickyalturino/.gvm/scripts/gvm"
