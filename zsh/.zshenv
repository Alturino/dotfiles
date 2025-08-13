# export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
# export PATH=$PATH:"$GEM_HOME/bin"
. "$HOME/.cargo/env"

export HISTSIZE=99999999999999
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.zsh_history"
export GRAPHVIZ_DOT=/usr/bin/dot
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
export PATH="$PATH:$GRAPHVIZ_DOT"
export PATH="$PATH:$HOME/.cargo/env"
export PATH="$PATH:$HOME/.maestro/bin"
export PATH="$PATH:$HOME/Android/Sdk/platform-tools"
export PATH="$PATH:$HOME/go/bin/"
export PATH="$PATH:/usr/local/go/bin/"
export PATH="$PATH:$HOME/.local/share/fnm"
export PATH="$PATH:$HOME/flutter/bin/"
export PATH="$PATH:$HOME/.local/bin"
export TERM="xterm-256color"


# Aliases
alias eza='eza '\''--icons'\'' '\''--git'\'''
alias la='eza -a'
alias ll='eza -l'
alias lla='eza -la'
alias ls='eza'
alias lt='eza --tree'
alias kitty='kitty --start-as maximized'


