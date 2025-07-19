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
sort_by=$4
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

# Extract URLs with line numbers to preserve position
urls=$(echo "$content" | grep -noE '(https?|ftp|file):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]')
wwws=$(echo "$content" | grep -noE '(http?s://)?www\.[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(/\S+)*' | grep -vE ':[0-9]*:https?://' | sed 's/^\([0-9]*\):\(.*\)$/\1:http:\/\/\2/')
ips=$(echo "$content" | grep -noE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/\S+)*' | sed 's/^\([0-9]*\):\(.*\)$/\1:http:\/\/\2/')
gits=$(echo "$content" | grep -noE '(ssh://)?git@\S*' | sed 's/:/\//g' | sed 's/^\([0-9]*\)\/\/\(ssh\/\/\/\)\{0,1\}git@\(.*\)$/\1:https:\/\/\3/')
gh=$(echo "$content" | grep -noE "['\"]([_A-Za-z0-9-]*/[_.A-Za-z0-9-]*)['\"]" | sed "s/['\"]//g" | sed 's/^\([0-9]*\):\(.*\)$/\1:https:\/\/github.com\/\2/')

if [[ $# -ge 1 && "$1" != '' ]]; then
    extras=$(echo "$content" | nl -nln | eval "$1" | sed 's/^\([0-9]*\)\t\(.*\)$/\1:\2/')
fi

# Combine all URLs with their line numbers
all_urls=$(printf '%s\n' "${urls[@]}" "${wwws[@]}" "${gh[@]}" "${ips[@]}" "${gits[@]}" "${extras[@]}" | grep -v '^$')

# Sort and deduplicate based on sort_by option
if [[ "$sort_by" == "recency" ]]; then
    # Recency behavior: adjust sort order based on fzf layout
    fzf_options="$(get_fzf_options)"
    if [[ "$fzf_options" == *"--reverse"* ]]; then
        # Reverse layout (search at top): oldest URLs first so recent ones are closest to search
        sort_order="-n"
    else
        # Default layout (search at bottom): newest URLs first so recent ones are closest to search
        sort_order="-nr"
    fi
    
    items=$(echo "$all_urls" | awk -F: '
        {
            url = substr($0, index($0, ":") + 1)
            if (!seen[url]) {
                seen[url] = 1
                print $1 ":" url
            }
        }' | sort $sort_order | cut -d: -f2- | nl -w3 -s '  ')
else
    # Default alphabetical behavior: sort alphabetically and remove duplicates
    items=$(echo "$all_urls" | cut -d: -f2- | sort -u | nl -w3 -s '  ')
fi
[ -z "$items" ] && tmux display 'tmux-fzf-url: no URLs found' && exit

fzf_filter <<< "$items" | awk '{print $2}' | \
    while read -r chosen; do
        open_url "$chosen" &>"/tmp/tmux-$(id -u)-fzf-url.log"
    done
