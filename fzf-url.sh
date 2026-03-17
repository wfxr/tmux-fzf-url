#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2218
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XRE="$SCRIPT_DIR/bin/xre"
XRE_VERSION="0.1.1"

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

# Standard URLs
#   https://example.com/path?q=1
#   ftp://files.example.com/file.tar.gz
read -r PAT_URL <<'PATTERN'
(?:https?|ftp|file):/?//[-\w+&@#/%?=~|!:,.;]*[-\w+&@#/%=~|]
PATTERN

# Git SSH URLs
#   git@github.com:user/repo.git -> https://github.com/user/repo.git
#   ssh://git@github.com/user/repo.git -> https://github.com/user/repo.git
read -r PAT_GIT <<'PATTERN'
(?:ssh://)?git@([^\s'"`:]+)[:/]([^\s'"`]+)
PATTERN
SUB_GIT='https://$1/$2'

# Bare www domains
#   www.example.com -> http://www.example.com
#   www.example.com/path -> http://www.example.com/path
read -r PAT_WWW <<'PATTERN'
www\.[a-zA-Z](?:-?[a-zA-Z0-9])+\.[a-zA-Z]{2,}(?:/[^\s'"`]+)*
PATTERN
SUB_WWW='http://$0'

# IP addresses
#   192.168.1.1 -> http://192.168.1.1
#   10.0.0.1:8080/api -> http://10.0.0.1:8080/api
read -r PAT_IP <<'PATTERN'
\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?::\d{1,5})?(?:/[^\s'"`]+)*
PATTERN
SUB_IP='http://$0'

# GitHub shorthand
#   'user/repo' -> https://github.com/user/repo
#   "my-org/my-repo" -> https://github.com/my-org/my-repo
read -r PAT_GH <<'PATTERN'
['"]([\w-]+/[\w.-]+)['"]
PATTERN
SUB_GH='https://github.com/$1'

ensure_xre() {
    if [ -x "$XRE" ]; then
        local current
        current="$("$XRE" --version 2>/dev/null | awk '{print $2}')"
        [ "$current" = "$XRE_VERSION" ] && return 0
        local msg="upgrading xre to v${XRE_VERSION}"
    else
        local msg="installing xre v${XRE_VERSION}"
    fi

    command -v curl &>/dev/null || { echo "tmux-fzf-url: 'curl' is required to install 'xre'" >&2; return 1; }

    local install_cmd
    printf -v install_cmd "curl -fsSL %q | bash -s -- -v %q -d %q" \
        "https://raw.githubusercontent.com/wfxr/xre/v${XRE_VERSION}/install.sh" \
        "v$XRE_VERSION" "$SCRIPT_DIR/bin"

    if [ -n "$TMUX" ]; then
        tmux display "tmux-fzf-url: ${msg}..."
    else
        echo "tmux-fzf-url: ${msg}..." >&2
    fi
    bash -c "$install_cmd" || {
        echo "tmux-fzf-url: failed to install 'xre'" >&2
        return 1
    }
    [ -x "$XRE" ]
}

xre_extract() {
    "$XRE" --strip-ansi \
        -e "$PAT_URL" \
        -e "$PAT_GIT" -r "$SUB_GIT" \
        -e "$PAT_WWW" -r "$SUB_WWW" \
        -e "$PAT_IP"  -r "$SUB_IP" \
        -e "$PAT_GH"  -r "$SUB_GH" \
        "$@"
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

if ! ensure_xre; then
    tmux display 'tmux-fzf-url: xre is required but could not be installed. See https://github.com/wfxr/xre'
    exit 1
fi

limit=$1
custom_open=$2
custom_copy=$3
custom_pat=$4
custom_sub=$5
[[ -z "$limit" ]] && limit='screen'

if [[ $limit == 'screen' ]]; then
    content="$(tmux capture-pane -J -p -e)"
else
    content="$(tmux capture-pane -J -p -e -S -"$limit")"
fi

custom_args=()
if [[ -n "$custom_pat" ]]; then
    custom_args+=(-e "$custom_pat")
    [[ -n "$custom_sub" ]] && custom_args+=(-r "$custom_sub")
fi

items=$(printf '%s\n' "$content" | xre_extract "${custom_args[@]}" | nl -w3 -s '  ')
[ -z "$items" ] && tmux display 'tmux-fzf-url: no URLs found' && exit

_copy_cmd=$(get_copy_cmd "$custom_copy")

fzf_filter <<<"$items" | awk '{print $2}' |
    while read -r chosen; do
        open_url "$chosen" &>"/tmp/tmux-$(id -u)-fzf-url.log"
    done
