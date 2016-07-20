dir_not_empty() { test "$(ls -A "$@" 2>/dev/null)" ;}

psudo() {
  local sudo=''; type 1>/dev/null su-exec && sudo=su-exec
  test ! "$sudo" && type 1>/dev/null gosu && sudo=gosu
  test ! "$sudo" && type 1>/dev/null sudo && sudo='sudo -u'
  test ! "$sudo" && echo >&2 "Please install su-exec, gosu or sudo" && return 1
  printf "$sudo"
}
