# tmux-fzf-url

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![Awesome](https://img.shields.io/badge/Awesome-tmux-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/rothgar/awesome-tmux)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2018)

A tmux plugin for opening urls from browser quickly without mouse.

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-fzf-url.gif)

### 📥 Installation

Prerequisites:

- [tmux](https://github.com/tmux/tmux) (>= 3.2)
- [tpm](https://github.com/tmux-plugins/tpm)
- [`fzf`](https://github.com/junegunn/fzf)
- [`bash`](https://www.gnu.org/software/bash/)

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

Add this line to your tmux config file, then hit `prefix + I`:

```tmux
set -g @plugin 'joshmedeski/tmux-fzf-url'
```

**Install manually**

Clone this repo somewhere and source `fzf-url.tmux` at the config file.

### 📝 Usage

The default key-binding is `u`(of course prefix hit is needed), it can be modified by
setting value to `@fzf-url-bind` at the tmux config like this:

```tmux
set -g @fzf-url-bind 'x'
```

You can also extend the capture groups by defining `@fzf-url-extra-filter`:

```tmux
# simple example for capturing files like 'abc.txt'
set -g @fzf-url-extra-filter 'grep -oE "\b[a-zA-Z]+\.txt\b"'
```

The plugin default captures the current screen. You can set `history_limit` to capture
the scrollback history:

```tmux
set -g @fzf-url-history-limit '2000'
```

You can use custom fzf options by defining `@fzf-url-fzf-options`.

```
# open tmux-fzf-url in a tmux v3.2+ popup
set -g @fzf-url-fzf-options '-w 50% -h 50% --multi -0 --no-preview --no-border'
```

### 💡 Tips

- You can mark multiple urls and open them at once.
- The tmux theme showed in the screenshot is [tmux-power](https://github.com/wfxr/tmux-power).

### 🔗 Other plugins

- [tmux-power](https://github.com/wfxr/tmux-power)
- [tmux-net-speed](https://github.com/wfxr/tmux-net-speed)

### 📃 License

[MIT](https://wfxr.mit-license.org/2018) (c) Wenxuan Zhang
