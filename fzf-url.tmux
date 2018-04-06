#!/usr/bin/env bash

# $1: option
# $2: default value
tmux_get() {
    local value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo $value || echo $2
}

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

url_reg='\b(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'
fzf_url_cmd="tmux capture-pane -J -p |grep -oE '"$url_reg"' |fzf-tmux"
if  hash xdg-open &>/dev/null; then
    open_cmd='nohup xdg-open'
elif hash open &>/dev/null; then
    open_cmd='open'
fi

key="$(tmux_get "@fzf-url-bind" "u")"

tmux bind-key "$key" run -b "tmux capture-pane -J -p |grep -oE '"$url_reg"' |sort -u |fzf-tmux | xargs $open_cmd &>/dev/null || true";
