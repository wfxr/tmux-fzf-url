#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

fzf_filter() {
    local fzf_version fzf_options copy_bind
    fzf_version="$(fzf --version 2>/dev/null | awk '{print $1}')"
    fzf_options="$(tmux show -gqv '@fzf-url-fzf-options')"
    copy_bind="ctrl-y:execute-silent(printf '%s\n' {+} | awk '{print \$2}' | $_copy_cmd)"

    if [ -n "$fzf_options" ]; then
        # Custom options are fzf-tmux flags — always use fzf-tmux
        eval "fzf-tmux $fzf_options --bind $(printf '%q' "$copy_bind")"
    elif version_ge "$fzf_version" "0.53.0"; then
        fzf --tmux center,100%,50% --multi --exit-0 --no-preview --bind "$copy_bind"
    else
        fzf-tmux -w 100% -h 50% --multi --exit-0 --no-preview --bind "$copy_bind"
    fi
}

open_url() {
    if [[ -n $custom_open ]]; then
        $custom_open "$@"
    elif [[ -n ${WSL_DISTRO_NAME:-} || -n ${WSL_INTEROP:-} ]]; then
        if hash wslview &>/dev/null; then
            nohup wslview "$@"
        else
            nohup explorer.exe "$@"
        fi
    elif hash xdg-open &>/dev/null; then
        nohup xdg-open "$@"
    elif hash open &>/dev/null; then
        nohup open "$@"
    elif [[ -n $BROWSER ]]; then
        nohup "$BROWSER" "$@"
    fi
}

strip_ansi() {
    sed -E 's/\x1B\[[0-9;]*[mK]//g'
}

extract_urls() {
    grep -oE '(https?|ftp|file):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'
}

extract_wwws() {
    grep -oE '(https?://)?www\.[a-zA-Z](-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(/[^[:space:]'"'"'"`]+)*' |
        grep -vE '^https?://' |
        sed 's/^\(.*\)$/http:\/\/\1/'
}

extract_ips() {
    grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/[^[:space:]'"'"'"`]+)*' |
        sed 's/^\(.*\)$/http:\/\/\1/'
}

extract_gits() {
    grep -oE '(ssh://)?git@[^[:space:]'"'"'"`]*' |
        sed 's/:/\//g' |
        sed 's/^\(ssh\/\/\/\)\{0,1\}git@\(.*\)$/https:\/\/\2/'
}

extract_gh() {
    grep -oE "['\"]([_A-Za-z0-9-]*/[_.A-Za-z0-9-]*)['\"]" |
        sed "s/['\"]//g" |
        sed 's#.#https://github.com/&#'
}

reverse_dedup() {
    awk '{lines[NR]=$0} END{for(i=NR;i>=1;i--)if(!seen[lines[i]]++)print lines[i]}'
}

get_copy_cmd() {
    local custom="$1"
    if [[ -n "$custom" ]]; then
        echo "$custom"
    elif [[ -n "${WSL_DISTRO_NAME:-}" || -n "${WSL_INTEROP:-}" ]] && hash clip.exe &>/dev/null; then
        echo "clip.exe"
    elif hash pbcopy &>/dev/null; then
        echo "pbcopy"
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && hash wl-copy &>/dev/null; then
        echo "wl-copy"
    elif [[ -n "${DISPLAY:-}" ]] && hash xclip &>/dev/null; then
        echo "xclip -selection clipboard"
    elif [[ -n "${DISPLAY:-}" ]] && hash xsel &>/dev/null; then
        echo "xsel --clipboard --input"
    else
        echo "tmux load-buffer -"
    fi
}

# Source guard: when testing, stop here and don't execute main logic
[[ "${__FZF_URL_TESTING:-}" == 1 ]] && return 0 2>/dev/null || true

custom_open=$3
custom_copy=$4
sort_mode=${5:-recency}
limit='screen'
[[ $# -ge 2 ]] && limit=$2

if [[ $limit == 'screen' ]]; then
    content="$(tmux capture-pane -J -p -e | strip_ansi)"
else
    content="$(tmux capture-pane -J -p -e -S -"$limit" | strip_ansi)"
fi

urls=$(echo "$content" | extract_urls)
wwws=$(echo "$content" | extract_wwws)
ips=$(echo "$content" | extract_ips)
gits=$(echo "$content" | extract_gits)
gh=$(echo "$content" | extract_gh)

if [[ $# -ge 1 && "$1" != '' ]]; then
    extras=$(echo "$content" | eval "$1")
fi

items=$(
    printf '%s\n' "${urls[@]}" "${wwws[@]}" "${gh[@]}" "${ips[@]}" "${gits[@]}" "${extras[@]}" |
        grep -v '^$' |
        if [[ "$sort_mode" == "alpha" ]]; then sort -u; else reverse_dedup; fi |
        nl -w3 -s '  '
)
[ -z "$items" ] && tmux display 'tmux-fzf-url: no URLs found' && exit

_copy_cmd=$(get_copy_cmd "$custom_copy")

fzf_filter <<<"$items" | awk '{print $2}' |
    while read -r chosen; do
        open_url "$chosen" &>"/tmp/tmux-$(id -u)-fzf-url.log"
    done
