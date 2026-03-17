PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
export __FZF_URL_TESTING=1
source "$PROJECT_ROOT/fzf-url.sh"
ensure_xre || { echo "Failed to install xre" >&2; exit 1; }
export -f version_ge get_copy_cmd xre_extract ensure_xre
export XRE XRE_VERSION PAT_URL PAT_GIT SUB_GIT PAT_WWW SUB_WWW PAT_IP SUB_IP PAT_GH SUB_GH
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
