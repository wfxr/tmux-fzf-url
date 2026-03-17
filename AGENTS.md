# AGENTS.md

## Project Overview

**tmux-fzf-url** is a tmux plugin that extracts URLs from terminal content and lets users quickly open them via fzf fuzzy selection, without using a mouse.

## Tech Stack

- **Language**: Bash + Rust (via [xre](https://github.com/wfxr/xre))
- **Dependencies**: `fzf`, `tmux`, `bash`, `xre` (auto-installed to `$SCRIPT_DIR/bin/`)
- **Platform**: Linux / macOS

## Repository Structure

```
├── fzf-url.tmux              # Plugin entry point: reads tmux options, registers keybinding
├── fzf-url.sh                # Core logic: captures pane content, extracts URLs, opens selection
├── test/
│   ├── libs/                 # bats-core, bats-assert, bats-support (git submodules)
│   ├── test_helper.bash      # Shared setup: source fzf-url.sh, load assertions
│   └── *.bats                # Test files for each extraction function
├── .github/workflows/test.yml # CI: cross-platform test matrix (ubuntu + macOS)
├── README.md                 # User documentation
├── LICENSE.txt               # MIT license
└── FUNDING.yml               # Sponsorship info
```

## Architecture

The plugin consists of two scripts:

1. **`fzf-url.tmux`** — Entry point loaded by TPM (or manually). Reads user configuration from tmux global options (`@fzf-url-*`) and binds a key to invoke `fzf-url.sh` with the resolved parameters.

2. **`fzf-url.sh`** — Core script invoked at runtime. It:
   - Captures the current tmux pane content (screen or scrollback)
   - Pipes content through `xre --strip-ansi` which handles ANSI stripping, multi-pattern URL extraction (with priority-based overlap prevention), replacement, and deduplication in a single pass
   - Optionally applies a user-defined custom pattern (`@fzf-url-custom-pat` / `@fzf-url-custom-sub`)
   - Numbers results and presents them via fzf for interactive selection (version-aware: `fzf --tmux` for >= 0.53.0, otherwise `fzf-tmux`)
   - Opens selected URLs using `xdg-open`, `open`, `$BROWSER`, or a custom command

## Configuration Options

All options are tmux global options set via `set -g`:

| Option                   | Default    | Description                              |
|--------------------------|------------|------------------------------------------|
| `@fzf-url-bind`         | `u`        | Key binding (after tmux prefix)          |
| `@fzf-url-history-limit`| `screen`   | Scrollback lines to capture              |
| `@fzf-url-fzf-options`  | `''`       | Custom fzf-tmux flags                   |
| `@fzf-url-open`         | `''`       | Custom command to open URLs              |
| `@fzf-url-custom-pat`   | `''`       | Custom xre regex pattern for extraction  |
| `@fzf-url-custom-sub`   | `''`       | Replacement template for custom pattern  |

## URL Pattern Types

The plugin extracts the following URL formats from pane content:

1. **Standard URLs** — `https?://`, `ftp://`, `file://`
2. **WWW URLs** — `www.example.com` (auto-prefixed with `http://`)
3. **IP addresses** — `192.168.1.1:8080/path` (wrapped as `http://`)
4. **Git SSH URLs** — `git@github.com:user/repo` (converted to `https://`)
5. **GitHub shorthand** — `'user/repo'` or `"user/repo"` (converted to `https://github.com/`)
6. **Custom patterns** — via `@fzf-url-custom-pat` / `@fzf-url-custom-sub`

## Development Guidelines

- Keep the codebase minimal — the entire plugin is two short shell scripts plus `xre` for extraction.
- The scripts use Bash features (`[[ ]]`, `$(...)`, etc.) and require `bash`.
- URL extraction is handled by `xre` via the `xre_extract` wrapper function. Pattern priority ensures higher-priority patterns (e.g., full URLs) consume byte ranges before lower-priority patterns (e.g., bare `www.` domains) can match overlapping text.
- When modifying fzf invocation, maintain backward compatibility with older fzf versions (the `version_ge` function handles version detection).
- Pane content is captured via `tmux capture-pane -J -p -e` and passed raw to `xre --strip-ansi`.
- Log output from URL opening goes to `/tmp/tmux-$(id -u)-fzf-url.log`.

## Testing

Automated tests use [bats-core](https://github.com/bats-core/bats-core) (added as git submodules):

```bash
# First-time setup (if cloned without --recurse-submodules)
git submodule update --init --recursive

# Run all tests
./test/libs/bats-core/bin/bats test/*.bats
```

The test suite covers the unified `xre_extract` function (all URL types, dedup, ANSI stripping), `version_ge`, and integration scenarios. URL extraction logic is also tested by `xre`'s own Rust test suite. `fzf-url.sh` exposes a source guard (`__FZF_URL_TESTING=1`) so tests can source the functions without executing the main logic.

GitHub Actions CI runs the tests on both ubuntu and macOS to catch GNU/BSD compatibility issues.

Manual testing is still recommended for end-to-end verification:

1. Install the plugin in a tmux session (via TPM or source `fzf-url.tmux`)
2. Display content containing various URL formats in the pane
3. Press `prefix + u` (or configured key) and verify URLs are correctly extracted and selectable
