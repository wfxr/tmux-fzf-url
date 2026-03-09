PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
export __FZF_URL_TESTING=1
source "$PROJECT_ROOT/fzf-url.sh"
export -f version_ge strip_ansi extract_urls extract_wwws extract_ips extract_gits extract_gh
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
