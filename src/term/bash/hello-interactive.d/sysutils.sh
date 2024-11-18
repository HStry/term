#!/usr/bin/env bash

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
    (*'R'*) C=41;;
    (*'G'*) C=42;;
    (*'B'*) C=44;;
    (*'C'*) C=46;;
    (*'M'*) C=45;;
    (*'Y'*) C=43;;
    (*'K'*) C=40;;
    (*'W'*) C=47;;
  esac
  case "$1" in
    (*'r'*) c=31;;
    (*'g'*) c=32;;
    (*'b'*) c=34;;
    (*'c'*) c=36;;
    (*'m'*) c=35;;
    (*'y'*) c=33;;
    (*'k'*) c=30;;
    (*'w'*) c=37;;
  esac
  case "$1" in
    (*'*'*) s=1;;
    (*'.'*) s=2;;
    (*'/'*) s=3;;
    (*'_'*) s=4;;
    (*'-'*) s=9;;
    (*'|'*) s=51;;
    (*'^'*) s=53;;
  esac
  shift
  cc="$(echo "$C;$c;$s" | sed -e 's/;\+/;/g' -e 's/^;//' -e 's/;$//')"
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
  local u d w
  if color; then
    u='[  '"$(colorize 'g*' UP)"'  ]'
    d='[ '"$(colorize 'r*' DOWN)"' ]'
    w='[ '"$(colorize 'y*' WAIT)"' ]'
  else
    u='[  UP  ]'
    d='[ DOWN ]'
    w='[ WAIT ]'
  fi
  
  for host in "$@"; do
    t=0; e=0
    while ! ping -q -w ${tw} -c 1 "${host}" > /dev/null 2>&1; do
      if [ "${t}" -gt "${timeout}" ]; then
        e=1; break
      else
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

export -f to_bool color colorize hosts_reachable hosts_reachable_wait qdig
