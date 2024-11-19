
whoamireally() {
  local n="$(who am i)"
  [ -n "${n}" ] && echo -en "${n}" && return 0
  
}

is_homedir() {
}
