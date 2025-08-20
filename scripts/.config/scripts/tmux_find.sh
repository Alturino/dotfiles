#!/usr/bin/env zsh

DIR=(
  "$HOME/Personal/coding/problem-solving"
  "$HOME/Personal/coding/projects"
  "$HOME/Personal/coding/oss"
  "$HOME/Personal/ricky_vault"
  "$HOME/Downloads"
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . "${DIR[@]}" --type=dir --max-depth=1 | fzf)
    [[ $selected ]] && selected="${selected}"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)
if ! tmux has-session -t "$selected_name"  ; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t "$selected_name"
