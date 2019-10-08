#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================

fzf_cmd() {
    fzf-tmux -d 35% --multi --exit-0 --cycle --reverse --bind='ctrl-r:toggle-all' --bind='ctrl-s:toggle-sort' --no-preview
}

if  hash xdg-open &>/dev/null; then
    open_cmd='nohup xdg-open'
elif hash open &>/dev/null; then
    open_cmd='open'
elif [[ -n $BROWSER ]]; then
    open_cmd="$BROWSER"
fi

content="$(tmux capture-pane -J -p)"
urls=($(echo "$content" |grep -oE '(https?|ftp|file):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'))
wwws=($(echo "$content" |grep -oE 'www\.[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(/\S+)*'                  |sed 's/^\(.*\)$/http:\/\/\1/'))
ips=($(echo  "$content" |grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/\S+)*' |sed 's/^\(.*\)$/http:\/\/\1/'))
gits=($(echo "$content" |grep -oE '(ssh://)?git@\S*' | sed 's/:/\//g' | sed 's/^\(ssh\/\/\/\)\{0,1\}git@\(.*\)$/https:\/\/\2/'))

merge() {
    for item in "$@" ; do
        echo "$item"
    done
}

merge "${urls[@]}" "${wwws[@]}" "${ips[@]}" "${gits[@]}"|
    sort -u |
    nl -w3 -s '  ' |
    fzf_cmd |
    awk '{print $2}'|
    xargs -n1 -I {} $open_cmd {} &>/dev/null ||
    true
