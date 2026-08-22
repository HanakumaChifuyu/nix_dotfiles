#!/usr/bin/env bash
# Apply the just-generated foot palette to every running foot terminal.
# foot reads foot.ini only at startup, but it accepts OSC 4/10/11/12 palette
# updates at runtime. tmux uses ANSI colour indexes, so its theme follows too.

set -euo pipefail

colors_file="${XDG_CACHE_HOME:-$HOME/.cache}/matugen/foot-colors.ini"
[[ -r "$colors_file" ]] || exit 0

declare -A color
while IFS='=' read -r key value; do
  case "$key" in
    foreground|background|cursor|regular[0-7]|bright[0-7])
      color["$key"]="${value%% *}"
      ;;
  esac
done <"$colors_file"

for key in foreground background cursor regular{0..7} bright{0..7}; do
  [[ "${color[$key]:-}" =~ ^[[:xdigit:]]{6}$ ]] || exit 0
done

# Find PTYs belonging to foot's server descendants. Writing to a slave PTY is
# terminal output, so OSC sequences are handled by foot rather than the shell.
mapfile -t terminals < <(
  ps -eo pid=,ppid=,tty= |
    awk -v roots="$(pgrep -d, -x foot 2>/dev/null || true)" '
      BEGIN {
        count = split(roots, root, ",")
        for (i = 1; i <= count; i++) if (root[i] != "") seen[root[i]] = 1
      }
      { pid[$1] = $1; parent[$1] = $2; tty[$1] = $3 }
      END {
        do {
          changed = 0
          for (id in pid)
            if (seen[parent[id]] && !seen[id]) { seen[id] = 1; changed = 1 }
        } while (changed)
        for (id in seen)
          if (tty[id] ~ /^pts\// && !printed[tty[id]]++) print "/dev/" tty[id]
      }'
)

for terminal in "${terminals[@]}"; do
  {
    printf '\e]10;#%s\e\\' "${color[foreground]}"
    printf '\e]11;#%s\e\\' "${color[background]}"
    printf '\e]12;#%s\e\\' "${color[cursor]}"
    for index in {0..7}; do
      printf '\e]4;%d;#%s\e\\' "$index" "${color[regular$index]}"
      printf '\e]4;%d;#%s\e\\' "$((index + 8))" "${color[bright$index]}"
    done
  } >"$terminal" 2>/dev/null || true
done

# Redraw attached tmux clients immediately. Its theme intentionally refers to
# colour0..colour15, which now resolve to foot's updated palette.
tmux refresh-client -S >/dev/null 2>&1 || true
