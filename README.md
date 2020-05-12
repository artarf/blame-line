# Blame Line

Show last git commit for a line

## Install

`apm install blame-line`

## Usage

Open blame-box by issuing command `blame-line:blame` or by pressing your custom keybinding.
There is a keybinding `s g b`, which works only in vim-mode-plus normal mode.

You can exit blame-box by
- moving to a different line
- pressing `ctrl-c`
- pressing `escape`

You can open the commit in browser by pressing `enter` while blame-box is open
(works only for [github](https://github.com/) and [bitbucket](https://bitbucket.org) currently).
