#!/usr/bin/env bash
# stry-term (bash) login script

stry-term() {
  local IFS=$'\n'
  local commands=( modules functions requirements )
  local arg_command
  local arg active_arg parse_args=1
  for arg in "$@"; do
    ((   parse_args )) && [[ "${arg}" == "--" ]] && parse_args=0 && continue
    (( ! parse_args )) && [[ "${arg}" == "++" ]] && parse_args=1 && continue
    if (( parse_args )) && [[ "${arg}" == "--"* ]]; then
    elif (( parse_args )) && [[ "${arg}" == "-"* ]]; then
    elif [[ -n "${active_arg}" ]]; then
    elif [[ -z "${arg_command}" ]] && [[ "${commands[@]}" =~ ^(.* )?${arg}( .*)?$ ]]; then
    else
      echo "Apologies, I dont understand provided command-line argument '${arg}'." >&2
      return 1
    fi
  done
}
