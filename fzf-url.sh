#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# shellcheck disable=SC2086
fzf_filter() {
    local fzf_version fzf_options
    fzf_version="$(fzf --version 2>/dev/null | awk '{print $1}')"
    fzf_options="$(tmux show -gqv '@fzf-url-fzf-options')"

    # fzf after version 0.53.0 supports native tmux integration
    if version_ge "$fzf_version" "0.53.0"; then
        fzf ${fzf_options:---tmux center,100%,50% --multi --exit-0 --no-preview}
    else
        fzf-tmux ${fzf_options:--w 100% -h 50% --multi --exit-0 --no-preview}
    fi
}

custom_open=$3
open_url() {
    if [[ -n $custom_open ]]; then
        $custom_open "$@"
    elif hash xdg-open &>/dev/null; then
        nohup xdg-open "$@"
    elif hash open &>/dev/null; then
        nohup open "$@"
    elif [[ -n $BROWSER ]]; then
        nohup "$BROWSER" "$@"
    fi
}

limit='screen'
[[ $# -ge 2 ]] && limit=$2

if [[ $limit == 'screen' ]]; then
    content="$(tmux capture-pane -J -p -e |sed -r 's/\x1B\[[0-9;]*[mK]//g'))"
else
    content="$(tmux capture-pane -J -p -e -S -"$limit" |sed -r 's/\x1B\[[0-9;]*[mK]//g'))"
fi

urls=$(echo "$content" |grep -oE '(https?|ftp|file):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]')
wwws=$(echo "$content" |grep -oE '(http?s://)?www\.[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(/\S+)*' | grep -vE '^https?://' |sed 's/^\(.*\)$/http:\/\/\1/')
ips=$(echo "$content" |grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/\S+)*' |sed 's/^\(.*\)$/http:\/\/\1/')
gits=$(echo "$content" |grep -oE '(ssh://)?git@\S*' | sed 's/:/\//g' | sed 's/^\(ssh\/\/\/\)\{0,1\}git@\(.*\)$/https:\/\/\2/')
gh=$(echo "$content" |grep -oE "['\"]([_A-Za-z0-9-]*/[_.A-Za-z0-9-]*)['\"]" | sed "s/['\"]//g" | sed 's#.#https://github.com/&#')

if [[ $# -ge 1 && "$1" != '' ]]; then
    extras=$(echo "$content" |eval "$1")
fi

items=$(printf '%s\n' "${urls[@]}" "${wwws[@]}" "${gh[@]}" "${ips[@]}" "${gits[@]}" "${extras[@]}" |
    grep -v '^$' |
    sort -u |
    nl -w3 -s '  '
)
[ -z "$items" ] && tmux display 'tmux-fzf-url: no URLs found' && exit

fzf_filter <<< "$items" | awk '{print $2}' | \
    while read -r chosen; do
        open_url "$chosen" &>"/tmp/tmux-$(id -u)-fzf-url.log"
    done
