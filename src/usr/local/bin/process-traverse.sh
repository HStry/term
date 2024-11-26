#!/usr/bin/env bash

proc_summary() {
  # returns brief proces info in the form
  # <Process ID>:<Parent process id>:<Process name>:<User id>:<User name>
  local pid ppid pname uid uname status
  for pid in "$@"; do
    status="$(cat "/proc/${pid}/status")"
    ppid="$(grep '^PPid:' <<< "${status}" | sed 's/^[^:]*:\s*//')"
    pname="$(grep '^Name:' <<< "${status}" | sed 's/^[^:]*:\s*//')"
    uid="$(grep '^Uid:' <<< "${status}" | awk '{print $2}')"
    uname="$(id -un "${uid}")"
    echo "${pid}:${ppid}:${pname}:${uid}:${uname}"
  done
}



whoamireally() {
  local n="$(who am i | awk '{print $1}')"
  [ -n "${n}" ] && echo -en "$(id -u "${n}") ${n}" && return 0
  declare -i pid ppid last_non_root
}

is_homedir() {
}
