#!/usr/bin/env bash

set -euo pipefail

cmd=(kitty)
if (($# > 0)); then
  cmd+=(-e "$@")
fi

shell_cmd="$(printf '%q ' "${cmd[@]}")"
shell_cmd="${shell_cmd% }"

lua_cmd="${shell_cmd//\\/\\\\}"
lua_cmd="${lua_cmd//\"/\\\"}"

exec hyprctl eval "hl.dispatch(hl.dsp.exec_cmd(\"$lua_cmd\", { float = true, center = true, size = { 1100, 720 } }))"
