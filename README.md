# tmux-fzf-url

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![Awesome](https://img.shields.io/badge/Awesome-zsh--plugins-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/rothgar/awesome-tmux)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2018)

A tmux plugin for opening urls from browser quickly without mouse.

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-fzf-url.gif)

### 📥 Installation

Make sure you have [`fzf`](https://github.com/junegunn/fzf) installed.

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

Add this line to your tmux config file, then hit `prefix + I`:

``` tmux
set -g @plugin 'wfxr/tmux-fzf-url'
```

**Install manually**

Clone this repo somewhere and source `fzf-url.tmux` at the config file.

### 📝 Usage

The default key-binding is `u`(of course prefix hit is needed), it can be modified by
setting value to `@fzf-url-bind` at the tmux config like this:

``` tmux
set -g @fzf-url-bind 'x'
```

### 💡 Tips

- Use `tab` to mark multiple urls and open them at once.
- Hit `ctrl - r` to toggle selection.
- The tmux theme showed at screenshot is [tmux-power](https://github.com/wfxr/tmux-power).

### 🔗 Other plugins

- [tmux-power](https://github.com/wfxr/tmux-power)
- [tmux-net-speed](https://github.com/wfxr/tmux-net-speed)

### 📃 License

[MIT](https://wfxr.mit-license.org/2018) (c) Wenxuan Zhang
