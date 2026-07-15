#! /usr/bin/env bash
set -euo pipefail

exec nvim -n -R -M \
    -c "setlocal buftype=nofile bufhidden=wipe noswapfile nomodifiable readonly wrap linebreak breakindent nonumber norelativenumber signcolumn=no foldcolumn=0 statuscolumn=" \
    -c "set laststatus=0 showtabline=0 noruler noshowmode" \
    -c "normal! G" \
    -
