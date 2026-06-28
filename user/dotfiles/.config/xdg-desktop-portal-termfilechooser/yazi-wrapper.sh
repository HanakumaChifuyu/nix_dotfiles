#!/usr/bin/env bash
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`

set -e

if [ "${6:-0}" -ge 4 ]; then
  set -x
fi

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

cmd="yazi"
termcmd="${TERMCMD:-kitty}"

if [ "$save" = "1" ]; then
  # save a file
  set -- --chooser-file="$out" "$path"
elif [ "$directory" = "1" ]; then
  # upload files from a directory
  set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
elif [ "$multiple" = "1" ]; then
  # upload multiple files
  set -- --chooser-file="$out" "$path"
else
  # upload only 1 file
  set -- --chooser-file="$out" "$path"
fi

case "$termcmd" in
kitty)
  kitty --title termfilechooser "$cmd" "$@"
  ;;
ghostty)
  ghostty --title=termfilechooser -e "$cmd" "$@"
  ;;
*)
  "$termcmd" "$cmd" "$@"
  ;;
esac

if [ "$directory" = "1" ]; then
  if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
    cat "$out"".1" >"$out"
    rm "$out"".1"
  else
    rm "$out"".1"
  fi
fi
