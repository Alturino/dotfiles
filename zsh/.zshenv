# export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
# export PATH=$PATH:"$GEM_HOME/bin"
. "$HOME/.cargo/env"

export PNPM_HOME="$HOME/.local/share/pnpm"
export ZSH="$HOME/.oh-my-zsh"
export HISTSIZE=99999999999999
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.zsh_history"
export GRAPHVIZ_DOT="/usr/bin/dot"
export NVM_DIR="$HOME/.nvm"
export TERM="xterm-256color"
export SDKMAN_DIR="$HOME/.sdkman"

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
export PATH="$PATH:$HOME/.opencode/bin"
export PATH="$PATH:/usr/bin"
export PATH="$PATH:$PNPM_HOME"
export SSLKEYLOGFILE="$HOME/.wireshark/sslkeylog.log"


export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
export ANTHROPIC_API_KEY=""
export ANTHROPIC_DEFAULT_OPUS_MODEL="anthropic/claude-opus-4.6"
export ANTHROPIC_DEFAULT_SONNET_MODEL="anthropic/claude-sonnet-4.6"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="anthropic/claude-haiku-4.5"
export CLAUDE_CODE_SUBAGENT_MODEL="anthropic/claude-sonnet-4.6"

