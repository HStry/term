if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "ERROR ('${BASH_SOURCE[0]}'): This script is intended to be sourced, not run." >&2
  exit 255
fi

self="$(realpath -s "${BASH_SOURCE[0]}")"
here="$(dirname "${self}")"

validate_int() {
  [[ "${1}" =~ ^(0|-?[1-9][0-9]*)$ ]] && echo -en ${1} && return 0
  echo "Value '${1}' isn't an integer." >&2
  return 1
}

math.min() {
  local v vmin=$(validate_int "${1}") || return 1; shift
  for v in "$@"; do
    v=$(validate_int "${v}") || return 1
    (( v < vmin )) && vmin=${v}
  done
  echo -en ${vmin}
}

math.max() {
  local v vmax=$(validate_int "${1}") || return 1; shift
  for v in "$@"; do
    v=$(validate_int "${v}") || return 1
    (( v > vmax )) && vmax=${v}
  done
  echo -en ${vmax}
}

math.sum() {
  local v vsum=0
  for v in "$@"; do
    v=$(validate_int "${v}") || return 1
    (( vsum+=v ))
  done
  echo -en ${vsum}
}

math.avg() {
  echo -en $(( $(math.sum "$@") / $# ))
}

export -f math.{min,max,sum,avg}
