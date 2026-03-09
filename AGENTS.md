# AGENTS.md

## Project Overview

**tmux-fzf-url** is a tmux plugin that extracts URLs from terminal content and lets users quickly open them via fzf fuzzy selection, without using a mouse.

## Tech Stack

- **Language**: Bash
- **Dependencies**: `fzf`, `tmux`, `bash`
- **Platform**: Linux / macOS

## Repository Structure

```
├── fzf-url.tmux       # Plugin entry point: reads tmux options, registers keybinding
├── fzf-url.sh         # Core logic: captures pane content, extracts URLs, opens selection
├── README.md          # User documentation
├── LICENSE.txt        # MIT license
└── FUNDING.yml        # Sponsorship info
```

## Architecture

The plugin consists of two scripts:

1. **`fzf-url.tmux`** — Entry point loaded by TPM (or manually). Reads user configuration from tmux global options (`@fzf-url-*`) and binds a key to invoke `fzf-url.sh` with the resolved parameters.

2. **`fzf-url.sh`** — Core script invoked at runtime. It:
   - Captures the current tmux pane content (screen or scrollback)
   - Strips ANSI escape sequences
   - Extracts URLs using multiple regex patterns (HTTP/HTTPS, www, IP, git SSH, GitHub shorthand)
   - Optionally applies a user-defined extra filter
   - Deduplicates and numbers results
   - Presents them via fzf for interactive selection (version-aware: `fzf --tmux` for >= 0.53.0, otherwise `fzf-tmux`)
   - Opens selected URLs using `xdg-open`, `open`, `$BROWSER`, or a custom command

## Configuration Options

All options are tmux global options set via `set -g`:

| Option                   | Default    | Description                              |
|--------------------------|------------|------------------------------------------|
| `@fzf-url-bind`         | `u`        | Key binding (after tmux prefix)          |
| `@fzf-url-history-limit`| `screen`   | Scrollback lines to capture              |
| `@fzf-url-extra-filter` | `''`       | Custom grep expression for extra patterns|
| `@fzf-url-fzf-options`  | `''`       | Custom fzf-tmux flags                   |
| `@fzf-url-open`         | `''`       | Custom command to open URLs              |

## URL Pattern Types

The plugin extracts the following URL formats from pane content:

1. **Standard URLs** — `https?://`, `ftp://`, `file://`
2. **WWW URLs** — `www.example.com` (auto-prefixed with `http://`)
3. **IP addresses** — `192.168.1.1:8080/path` (wrapped as `http://`)
4. **Git SSH URLs** — `git@github.com:user/repo` (converted to `https://`)
5. **GitHub shorthand** — `'user/repo'` or `"user/repo"` (converted to `https://github.com/`)
6. **Custom patterns** — via `@fzf-url-extra-filter`

## Development Guidelines

- Keep the codebase minimal — the entire plugin is two short shell scripts.
- Use POSIX-compatible constructs where possible; the scripts run under `bash`.
- URL regex patterns in `fzf-url.sh` are intentionally kept as `grep -oE` expressions for simplicity.
- When modifying fzf invocation, maintain backward compatibility with older fzf versions (the `version_ge` function handles version detection).
- Pane content is captured via `tmux capture-pane -J -p -e` and ANSI sequences are stripped with `sed`.
- Log output from URL opening goes to `/tmp/tmux-$(id -u)-fzf-url.log`.

## Testing

There is no automated test suite. Manual testing workflow:

1. Install the plugin in a tmux session (via TPM or source `fzf-url.tmux`)
2. Display content containing various URL formats in the pane
3. Press `prefix + u` (or configured key) and verify URLs are correctly extracted and selectable
4. Test with different `@fzf-url-*` option combinations
5. Test on both Linux (`xdg-open`) and macOS (`open`)
