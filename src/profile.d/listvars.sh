listvars() {
  local _lvlocal_helpmsg="$(cat << EOF
usage:
  listvars [OPTIONS]

OPTIONS:
  -h, -?, --help     Show this help message
  -f, --functions    List functions
  -v, --variables    List variables (default)
  -h, --hidden       Show objects starting with underscores
  -a, --all          Show regular and hidden objects
  -C, --no-column    Do not columnize the output

EXAMPLES:
  Show everything.
  $ listvars -avf
  
  Show only hidden functions (e.g. completions).
  $ listvars -hf
EOF
)"

  local _lvlocal_help=0
  local _lvlocal_functions=0
  local _lvlocal_variables=0
  local _lvlocal_hidden=0
  local _lvlocal_all=0
  local _lvlocal_column=1
  local _lvlocal_colcmd="$(type -P column)"
  local _lvlocal_a _lvlocal_arg _lvlocal_keys

  local _lvlocal_parse_args=1
  for _lvlocal_arg in "$@"; do
    [ $_lvlocal_parse_args -gt 0 -a "${_lvlocal_arg}" = '--' ] && _lvlocal_parse_args=0 && continue
    [ $_lvlocal_parse_args -eq 0 -a "${_lvlocal_arg}" = '++' ] && _lvlocal_parse_args=1 && continue
    [ $_lvlocal_parse_args -gt 0 ] && echo "${_lvlocal_arg}" | grep -q '^--' \
    && case "${_lvlocal_arg}" in
      '--help')      _lvlocal_help=1;;
      '--functions') _lvlocal_functions=1;;
      '--variables') _lvlocal_variables=1;;
      '--hidden')    _lvlocal_hidden=1;;
      '--all')       _lvlocal_all=1;;
      '--no-column') _lvlocal_column=0;;
      *) echo "Argument '${_lvlocal_arg}' not recognized." >&2;
         return 1;;
    esac && continue
    [ $_lvlocal_parse_args -gt 0 ] && echo "${_lvlocal_arg}" | grep -q '^-[a-zA-Z0-9?]\+' \
    && for _lvlocal_a in $(echo "${_lvlocal_arg}" | sed -e 's/\(.\)/ \1/g' -e 's/^[ -]*//'); do
      case "${_lvlocal_a}" in
        'h'|'?') _lvlocal_help=1;;
        'f')     _lvlocal_functions=1;;
        'v')     _lvlocal_variables=1;;
        'h')     _lvlocal_hidden=1;;
        'a')     _lvlocal_all=1;;
        'C')     _lvlocal_column=0;;
        *) echo "Argument '-${_lvlocal_a}' not recognized." >&2;
           return 1;;
      esac
    done && continue
    [ $_lvlocal_parse_args -gt 0 ] && echo "${_lvlocal_arg}" | grep -q '^-' \
    && echo "Argument '${_lvlocal_arg}' not recognized." >&2 && return 1
  done
  [ $_lvlocal_help -gt 0 ] && echo "${_lvlocal_helpmsg}" >&2 && return
  
  if [ $_lvlocal_variables -gt 0 -o $_lvlocal_functions -eq 0 ]; then
    _lvlocal_keys="$(set | grep -v '^_lvlocal_' | grep '^[^ ]\+=' | sed -e 's/=.*$//')"
    if [ $_lvlocal_all -eq 0 -a $_lvlocal_hidden -eq 0 ]; then
      _lvlocal_keys="$(echo "${_lvlocal_keys}" | grep '^[a-zA-Z0-9]')"
    elif [ $_lvlocal_all -eq 0 -a $_lvlocal_hidden -gt 0 ]; then
      _lvlocal_keys="$(echo "${_lvlocal_keys}" | grep -v '^[a-zA-Z0-9]')"
    fi
    if [ $_lvlocal_column -eq 0 -o -z "${_lvlocal_colcmd}" ]; then
      echo "${_lvlocal_keys}"
    else
      echo "${_lvlocal_keys}" | "${_lvlocal_colcmd}"
    fi
  fi
  
  if [ $_lvlocal_functions -gt 0 ]; then
    _lvlocal_keys="$(set | grep -v '^_lvlocal_' | grep '^[^ ].*[^= ]\s*()\s*$' | sed -e 's/\s*()\s*$/()/')"
    if [ $_lvlocal_all -eq 0 -a $_lvlocal_hidden -eq 0 ]; then
      _lvlocal_keys="$(echo "${_lvlocal_keys}" | grep '^[a-zA-Z0-9]')"
    elif [ $_lvlocal_all -eq 0 -a $_lvlocal_hidden -gt 0 ]; then
      _lvlocal_keys="$(echo "${_lvlocal_keys}" | grep -v '^[a-zA-Z0-9]')"
    fi
    if [ $_lvlocal_column -eq 0 -o -z "${_lvlocal_colcmd}" ]; then
      echo "${_lvlocal_keys}"
    else
      echo "${_lvlocal_keys}" | "${_lvlocal_colcmd}"
    fi
  fi
}
