dir_not_empty() { test "$(ls -A "$@" 2>/dev/null)" ;}
foreach() { local cmd="$1"; shift; for i; do $cmd "$i"; done ;}
argsep() { local IFS="$1"; shift; local cmd="$1"; shift; set -- $@; $cmd "$@" ;}

find_lib_dir() { for m in /lib/x86_64-linux-gnu /lib64; do test -e "$m" && echo $m && break; done ;}

# command lib_repo
ldd_fix() {
  local bin="$1" lib_repo="${2:-/mnt-lib-repo}"
  local main_lib_dir="$(find_lib_dir)" loops=0
  test -d "$main_lib_dir" || { echo "Main lib dir missing: '$main_lib_dir'"; return 1 ;}

  while true; do
    ldd $(which "$bin") | egrep '\s*not found' |
    while IFS= read -r line; do
      line="$(echo $(echo $line | cut -d= -f1))"
      echo "'[ldd_fix] $lib_repo/$line' -> '$main_lib_dir'/"
      ln -s "$lib_repo/$line" "$main_lib_dir"/ || return
    done
    loops=$((loops + 1))
    test $loops -le 400 || return
    ldd $(which "$bin") | egrep -q '\s*not found' || break
  done

}

linklogfiles() {
  mkfifo -m 600 /tmp/logpipe_out && mkfifo -m 600 /tmp/logpipe_err && \
  chown "$1" /tmp/logpipe* && shift || return
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
