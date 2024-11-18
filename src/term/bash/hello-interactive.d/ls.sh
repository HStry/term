#!/usr/bin/env bash

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "ERROR ('${BASH_SOURCE[0]}'): This script is intended to be sourced, not run." >&2
  exit 255
fi

_self="$(realpath "${BASH_SOURCE[0]}")"
_path="$(dirname "${_self}")"
_file="$(basename "${_self}")"
_name="${_file%.*}"

unalias ls ll lz l 2> /dev/null

declare -xa LSOPTS LLOPTS
if [[ -n "${LS_OPTIONS[@]}" ]]; then
  for opt in ${LS_OPTIONS[@]}; do
    LSOPTS+=( "${opt}" )
  done
else
  LSOPTS+=( --almost-all )
  LSOPTS+=( --classify )
  LSOPTS+=( --group-directories-first )
  LSOPTS+=( --color=auto )
fi
if [[ -n "${LL_OPTIONS[@]}" ]]; then
  for opt in ${LL_OPTIONS[@]}; do
    LLOPTS+=( "${opt}" )
  done
else
  LLOPTS+=( --human-readable )
  LLOPTS+=( --format=long )
fi

ls() {
  $(type -P ls) "${LSOPTS[@]}" "$@"
}
ll() {
  $(type -P ls) "${LSOPTS[@]}" "${LLOPTS[@]}" "$@"
}
lz() {
  $(type -P ls) "${LSOPTS[@]}" "${LLOPTS[@]}" --context "$@"
}
l() {
  $(type -P ls) "${LSOPTS[@]}" --format=single-column "$@"
}

export -f ls ll lz l
