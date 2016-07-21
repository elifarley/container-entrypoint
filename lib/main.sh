dir_not_empty() { test "$(ls -A "$@" 2>/dev/null)" ;}
foreach() { local cmd="$1"; shift; for i; do $cmd "$i"; done ;}
argsep() { local IFS="$1"; shift; local cmd="$1"; shift; set -- $@; $cmd "$@" ;}

linklogfiles() {
  eval $sudo mkfifo -m 600 /tmp/logpipe_out && eval $sudo mkfifo -m 600 /tmp/logpipe_err || \
    return
  cat <> /tmp/logpipe_out &
  cat <> /tmp/logpipe_err >&2 &
  argsep ',;' foreach linklogfile "$@"
}

linklogfile() {
  local logfile="$1";
  local target="${logfile##*:}"; test ! "$target" -o "$target" = "$logfile" && target='out'
  logfile="${logfile%%:*}"; test -L "$logfile" -o -e "$logfile" && ls -Falk "$logfile" && return
  ln -vsf /tmp/logpipe_"$target" "$logfile"
}

psudo() {
  local sudo=''; type 1>/dev/null su-exec && sudo=su-exec
  test ! "$sudo" && type 1>/dev/null gosu && sudo=gosu
  test ! "$sudo" && type 1>/dev/null sudo && sudo='sudo -u'
  test ! "$sudo" && echo >&2 "Please install su-exec, gosu or sudo" && return 1
  test "$1" && if ! getent >/dev/null passwd "$1"; then id "$1"; return; fi
  printf "$sudo${1:+ $1}"
}
