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
extra_filter="$(tmux_get '@fzf-url-extra-filter' '')"
custom_open="$(tmux_get '@fzf-url-open' '')"
echo "$extra_filter" > /tmp/filter

tmux bind-key "$key" run -b "$SCRIPT_DIR/fzf-url.sh '$extra_filter' $history_limit '$custom_open'";
