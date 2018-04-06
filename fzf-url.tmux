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

fzf_cmd="fzf-tmux --multi --cycle --reverse --bind='ctrl-u:half-page-up' --bind='ctrl-d:half-page-down' --bind='ctrl-r:toggle-all' --bind='ctrl-s:toggle-sort'"
url_regex='\b(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'
if  hash xdg-open &>/dev/null; then
    open_cmd='nohup xdg-open'
elif hash open &>/dev/null; then
    open_cmd='open'
fi

key="$(tmux_get "@fzf-url-bind" "u")"

tmux bind-key "$key" run -b "tmux capture-pane -J -p |grep -oE '"$url_regex"' |sort -u |nl -w3 -s'  ' |$fzf_cmd |awk '{print \$2}'| xargs $open_cmd &>/dev/null || true";
