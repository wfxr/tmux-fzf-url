# tmux-fzf-url

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![Awesome](https://img.shields.io/badge/Awesome-tmux-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/rothgar/awesome-tmux)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2018)

A tmux plugin for opening urls from browser quickly without mouse.

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-fzf-url.gif)

### 📥 Installation

Prerequisites:
* [`tmux`](https://github.com/tmux/tmux)
* [`fzf`](https://github.com/junegunn/fzf)
* [`bash`](https://www.gnu.org/software/bash/)
* [`xre`](https://github.com/wfxr/xre) *(auto-installed on first use)*

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

Add this line to your tmux config file, then hit `prefix + I`:

``` tmux
set -g @plugin 'wfxr/tmux-fzf-url'
```

**Install manually**

``` bash
git clone https://github.com/wfxr/tmux-fzf-url ~/.tmux/plugins/tmux-fzf-url
```

Then add the following line to your `~/.tmux.conf`:

``` tmux
run-shell ~/.tmux/plugins/tmux-fzf-url/fzf-url.tmux
```

**Legacy version (no `xre` dependency)**

If you prefer the older version that uses `grep` instead of `xre`, pin to the `legacy` tag:

``` tmux
set -g @plugin 'wfxr/tmux-fzf-url#legacy'
```

Or for a manual install:

``` bash
git clone -b legacy https://github.com/wfxr/tmux-fzf-url ~/.tmux/plugins/tmux-fzf-url
```

### 📝 Usage

The default key-binding is `u`(of course prefix hit is needed), it can be modified by
setting value to `@fzf-url-bind` at the tmux config like this:

``` tmux
set -g @fzf-url-bind 'x'
```

You can add a custom extraction pattern via `@fzf-url-custom-pat` (regex) and
optionally `@fzf-url-custom-sub` (replacement):

``` tmux
# capture files like 'abc.txt'
set -g @fzf-url-custom-pat '\b[a-zA-Z]+\.txt\b'

# capture Jira ticket IDs and turn them into URLs
set -g @fzf-url-custom-pat '[A-Z]+-\d+'
set -g @fzf-url-custom-sub 'https://jira.example.com/browse/$0'
```

The plugin default captures the current screen. You can set `history_limit` to capture
the scrollback history:

```tmux
set -g @fzf-url-history-limit '2000'
```

You can use custom fzf options by defining `@fzf-url-fzf-options`.

```tmux
# these options are passed to fzf-tmux
set -g @fzf-url-fzf-options '-w 50% -h 50% --multi -0 --no-preview --no-border'
```

By default, `tmux-fzf-url` will use `xdg-open`, `open`, or the `BROWSER`
environment variable to open the url, respectively. If you want to use a
different command, you can set `@fzf-url-open` to the command you want to use.

```tmux
set -g @fzf-url-open "firefox"
```

You can copy a URL to the clipboard instead of opening it by pressing `ctrl-y`
inside the fzf popup (the popup stays open). By default the plugin auto-detects
the clipboard tool (`clip.exe` on WSL2, `pbcopy` on macOS, `wl-copy` on Wayland,
`xclip`/`xsel` on X11, or `tmux load-buffer` as a fallback). You can override
this with:

```tmux
set -g @fzf-url-copy-cmd 'xclip -selection clipboard'
```

### 🔍 Supported URL Types

The plugin automatically recognizes and extracts the following formats:

- **Standard URLs** — `https://`, `http://`, `ftp://`, `file://`
- **WWW URLs** — `www.example.com` (auto-prefixed with `http://`)
- **IP addresses** — `192.168.1.1`, `10.0.0.1:8080/path`
- **Git SSH URLs** — `git@github.com:user/repo` (converted to `https://`)
- **GitHub shorthand** — `'user/repo'` or `"user/repo"` (converted to `https://github.com/`)
- **Custom patterns** — via `@fzf-url-custom-pat` / `@fzf-url-custom-sub`

### 💡 Tips

- You can mark multiple urls and open them at once.
- The tmux theme shown in the screenshot is [tmux-power](https://github.com/wfxr/tmux-power).

### 🛠️ Development

``` bash
# Clone with test dependencies
git clone --recurse-submodules https://github.com/wfxr/tmux-fzf-url
cd tmux-fzf-url

# Run tests
./test/libs/bats-core/bin/bats test/*.bats
```

Tests use [bats-core](https://github.com/bats-core/bats-core). If you already cloned without `--recurse-submodules`, run:

``` bash
git submodule update --init --recursive
```

### 🧩 Similar projects

- [tmux-fzf-links](https://github.com/alberti42/tmux-fzf-links): A more versatile tmux plugin that allows you to search for and open links.

### 🔗 Other plugins

- [tmux-power](https://github.com/wfxr/tmux-power)
- [tmux-net-speed](https://github.com/wfxr/tmux-net-speed)

### 📃 License

[MIT](https://wfxr.mit-license.org/2018) (c) Wenxuan Zhang
