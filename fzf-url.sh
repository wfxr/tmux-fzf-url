#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================

fzf_filter() {
    fzf-tmux -d 35% -m -0 --no-preview --no-border
}

open_url() {
    if hash xdg-open &>/dev/null; then
        nohup xdg-open "$@"
    elif hash open &>/dev/null; then
        nohup open "$@"
    elif [[ -n $BROWSER ]]; then
        nohup "$BROWSER" "$@"
    fi
}

content="$(tmux capture-pane -J -p -S -"$2")"

mapfile -t urls < <(echo "$content" |grep -oE '(https?|ftp|file):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]')
mapfile -t wwws < <(echo "$content" |grep -oE 'www\.[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(/\S+)*'                  |sed 's/^\(.*\)$/http:\/\/\1/')
mapfile -t ips  < <(echo "$content" |grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/\S+)*' |sed 's/^\(.*\)$/http:\/\/\1/')
mapfile -t gits < <(echo "$content" |grep -oE '(ssh://)?git@\S*' | sed 's/:/\//g' | sed 's/^\(ssh\/\/\/\)\{0,1\}git@\(.*\)$/https:\/\/\2/')

if [[ $# -ge 1 && "$1" != '' ]]; then
    mapfile -t extras < <(echo "$content" |eval "$1")
fi

items=$(printf '%s\n' "${urls[@]}" "${wwws[@]}" "${ips[@]}" "${gits[@]}" "${extras[@]}" |
    grep -v '^$' |
    sort -u |
    nl -w3 -s '  '
)
[ -z "$items" ] && exit

mapfile -t chosen < <(fzf_filter <<< "$items" | awk '{print $2}')

for item in "${chosen[@]}"; do
    open_url "$item" &>"/tmp/tmux-$(id -u)-fzf-url.log"
done
