#!/usr/bin/env bash

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "ERROR ('${BASH_SOURCE[0]}'): This script is intended to be sourced, not run." >&2
  exit 255
fi

_self="$(realpath "${BASH_SOURCE[0]}")"
_path="$(dirname "${_self}")"
_file="$(basename "${_self}")"
_name="${_file%.*}"

to_bool() {
  local a
  for a in "$@"; do
    case "${a,,}" in
      '1'|'y'|'yes'|'true') echo 1;;
      '0'|'n'|'no'|'false') echo 0;;
      *) return 1;;
    esac
  done
  return 0
}

color() {
  local c
  c=$(to_bool "${COLOR:-${COLOUR}}") && [ ${c} -eq 0 ] && return 1
  tput setaf 1 > /dev/null 2>&1
}

colorize() {
  local cc C c s
  case "$1" in
    (*'R'*) cc="${cc};41";;
    (*'G'*) cc="${cc};42";;
    (*'B'*) cc="${cc};44";;
    (*'C'*) cc="${cc};46";;
    (*'M'*) cc="${cc};45";;
    (*'Y'*) cc="${cc};43";;
    (*'K'*) cc="${cc};40";;
    (*'W'*) cc="${cc};47";;
  esac
  case "$1" in
    (*'r'*) cc="${cc};31";;
    (*'g'*) cc="${cc};32";;
    (*'b'*) cc="${cc};34";;
    (*'c'*) cc="${cc};36";;
    (*'m'*) cc="${cc};35";;
    (*'y'*) cc="${cc};33";;
    (*'k'*) cc="${cc};30";;
    (*'w'*) cc="${cc};37";;
  esac
  case "$1" in
    (*'*'*) cc="${cc};1";;
  esac
  case "$1" in
    (*'.'*) cc="${cc};2";;
  esac
  case "$1" in
    (*'/'*) cc="${cc};3";;
  esac
  case "$1" in
    (*'_'*) cc="${cc};4";;
  esac
  case "$1" in
    (*'-'*) cc="${cc};9";;
  esac
  case "$1" in
    (*'|'*) cc="${cc};51";;
  esac
  case "$1" in
    (*'^'*) cc="${cc};53";;
  esac
  shift
  cc="$(echo "${cc}" | sed -e 's/;\+/;/g' -e 's/^;//' -e 's/;$//')"
  echo '\e['"${cc}"'m'"$@"'\e[0m'
}

hosts_reachable() {
  local u d rc=0
  if color; then
    u='[  '"$(colorize 'g*' UP)"'  ]'
    d='[ '"$(colorize 'r*' DOWN)"' ]'
  else
    u='[  UP  ]'
    d='[ DOWN ]'
  fi
  
  for host in "$@"; do
    if ping -q -w 1 -c 1 "${host}" > /dev/null 2>&1; then
      echo -e "${u} ${host}"
    else
      rc=1
      echo -e "${d} ${host}"
    fi
  done
  return $rc
}

hosts_reachable_wait() {
  local t ts="${SLEEP:-5}" tw="${WAIT:-1}" timeout="${TIMEOUT:-600}"
  local rc=0 e=0
  local u d w wi wu wl
  if color; then
    u='[  '"$(colorize 'g*' UP)"'  ]'
    d='[ '"$(colorize 'r*' DOWN)"' ]'
    wu='[ '"$(colorize 'y*' WAIT)"' ]'
    wl='[ '"$(colorize 'y/' wait)"' ]'
  else
    u='[  UP  ]'
    d='[ DOWN ]'
    wu='[ WAIT ]'
    wl='[ wait ]'
  fi
  
  for host in "$@"; do
    t=0; e=0; wi=0
    while ! ping -q -w ${tw} -c 1 "${host}" > /dev/null 2>&1; do
      if [ "${t}" -gt "${timeout}" ]; then
        e=1; break
      else
        if [ ${wi} -eq 0 ]; then
          wi=1; w="${wu}"
        else
          wi=0; w="${wl}"
        fi
        echo -en "${w} ${host}\r"
        t=$(expr ${t} + ${ts} + ${tw})
        sleep "${ts}"
      fi
    done
    if [ ${e} -gt 0 ]; then
      rc=1
      echo -e "${d} ${host}"
    else
      echo -e "${u} ${host}"
    fi
  done
  return $rc
}

qdig() {
  dig $@ | grep -v '^\s*\(;\|$\)'
}

sys.findcmd() {
  [[ -z "${1}" ]] && echo "Missing command argument." >&2 && return 1
  local IFS=$'\n'
  local path paths=( $(for path in $(echo "${PATH}" | tr ':' '\n'); do
                         path="$(realpath "${path}" 2> /dev/null)"
                         [[ -d "${path}" ]] && echo "${path}"
                       done | sort -u) )
  local name
  for name in "$@"; do
    find "${paths[@]}" -maxdepth 1 -executable -iname "${name}"
  done | sort -u
}

# With regards to sys.findcmd; wanted to do a single run, but couldn't
# get the code below to work, fucking globbing gets in the way.
#   local name names=()
#   for name in "$@"; do
#     names+=( -or )
#     names+=( -iname )
#     names+=( $(echo "${name}" | sed -e 's/\*/\\\*/') )
#   done
#   unset names[0]
#   find "${paths[@]}" -maxdepth 1 -executable "${names[@]}"

users_can_sudo() {
  for u in "$@"; do
    [ $(id -u "${u}" 2> /dev/null || echo 1) -eq 0 ] \
    || getent group sudo wheel \
       | sed -e 's/^\([^:]*:\)\{3\}//' \
       | grep -q '\(^\|,\)'"${u}"'\(,\|$\)' \
    || return 1
  done
  return 0
}

export -f to_bool color colorize hosts_reachable hosts_reachable_wait qdig sys.findcmd
