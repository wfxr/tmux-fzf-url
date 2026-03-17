#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 09:30
#===============================================================================
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# $1: option
# $2: default value
tmux_get() {
    local value
    value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

key="$(tmux_get '@fzf-url-bind' 'u')"
history_limit="$(tmux_get '@fzf-url-history-limit' 'screen')"
custom_open="$(tmux_get '@fzf-url-open' '')"
custom_copy="$(tmux_get '@fzf-url-copy-cmd' '')"
custom_pat="$(tmux_get '@fzf-url-custom-pat' '')"
custom_sub="$(tmux_get '@fzf-url-custom-sub' '')"

# -N flag requires tmux >= 3.1
tmux_version="$(tmux -V | sed 's/[^0-9.]//g')"
note_flag=()
if [ "$(printf '%s\n' "3.1" "$tmux_version" | sort -V | head -n1)" = "3.1" ]; then
    note_flag=(-N "Open URLs with fzf")
fi

cmd=$(printf '%q ' "$SCRIPT_DIR/fzf-url.sh" "$history_limit" "$custom_open" "$custom_copy" "$custom_pat" "$custom_sub")
tmux bind-key "${note_flag[@]}" "$key" run -b "$cmd"
