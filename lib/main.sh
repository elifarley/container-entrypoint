dir_not_empty() { test "$(ls -A "$@" 2>/dev/null)" ;}
foreach() { local cmd="$1"; shift; for i; do $cmd "$i"; done ;}
argsep() { local IFS="$1"; shift; local cmd="$1"; shift; set -- $@; $cmd "$@" ;}

linklogfiles() { argsep ',;' foreach linklogfile "$@" ;}
linklogfile() {
  local logfile="$1";
  local target="${logfile##*:}"; test ! "$target" -o "$target" = "$logfile" && target='out'
  case "$target" in out) target=1;; err) target=2;; *) echo "Invalid target: '$target'"; return 1 ;; esac
  logfile="${logfile%%:*}"; test -L "$logfile" -o -e "$logfile" && ls -Falk "$logfile" && return
  ln -vsf /proc/self/fd/"$target" "$logfile"
}

psudo() {
  local sudo=''; type 1>/dev/null su-exec && sudo=su-exec
  test ! "$sudo" && type 1>/dev/null gosu && sudo=gosu
  test ! "$sudo" && type 1>/dev/null sudo && sudo='sudo -u'
  test ! "$sudo" && echo >&2 "Please install su-exec, gosu or sudo" && return 1
  test "$1" && if ! getent >/dev/null passwd "$1"; then id "$1"; return; fi
  printf "$sudo${1:+ $1}"
}
