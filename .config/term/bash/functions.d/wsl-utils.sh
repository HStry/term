[[ -z "${IS_WSL}" ]] && exit

repeat() {
  local i n="${1:-80}" c="${2:- }"
  for (( i=0; i<n; i++ )); do echo -n "${c}"; done; echo
}

readfile() {
  f="${1:--}"
  [[ "${f}" == '-' ]] && [[ ! -t 0 ]] && cat && return
  [[ -f "${f}" ]] && [[ -r "${f}" ]] && cat "${f}" && return
  if [[ "${f}" == '-' ]]; then
    msg="Interactive mode does not support fetching data from stdin."
  elif [[ ! -f "${f}" ]]; then
    msg="Input file '${f}' does not appear to actually be a file."
  elif [[ ! -r "${f}" ]]; then
    msg="Input file '${f}' cannot be read."
  else
    msg="Unspecified error occurred attempting to read '${f}'."
  fi
  echo msg >&2
  return 1
}

wslxpath() {
  [[ -z "$1" ]] && echo "Missing 'path' parameter" >&2 && return 9
  local x="$(openssl rand -hex 16)"
  local winpaths="$(echo "$1" | sed -e "s/\(^\|;\)\([A-Z]\+:\\\\\)/${x}\2/g")"
  local i n="$(echo "${winpaths}" | grep -o "${x}" | wc -l)"
  (( ! n )) && echo "$1" && return 2
  
  local winpath linuxpaths=()
  for (( i=0; i<n; i++ )); do
    winpaths="${winpaths:${#x}}"
    winpath="${winpaths%%${x}*}"
    linuxpaths+=( "$(wslpath "${winpath}" | sed -e 's/:/\\:/g')" )
    winpaths="${winpaths:${#winpath}}"
  done
  for (( i=0; i<n; i++ )); do
    (( i )) && echo -n ":"
    echo -n "${linuxpaths[$i]}"
  done
  echo
}

winenv() {
  [[ -z "$1" ]] && echo "Missing 'environment variable' parameter" >&2 && return 1
  echo "$(cmd.exe /c echo %${1}% 2>/dev/null | tr -d '\r')"
}

winpenv() {
  wslxpath "$(winenv "$1")"
}

wgfmt() {
# Define local parameters
  local IFS=$'\n'
  local default_file='-'
  local default_column default_columns=( "id" "name" "version" "available" )
  local default_source default_sources=( "winget" )
  local help_msg="$(cat << EOF
USAGE:
  winget <args> | wgfmt [OPTIONS]

OPTIONS:
  -h, --help          Show this help message
  -S, --all-sources   Show results from all sources
  -C, --all-columns   Show all columns
  -A, --all           Same as -SC
  -H, --header-only   Only output the header
  -s, --sources     [SOURCE [SOURCE...]]
                      Only show results from specified sources
  -c, --columns     [COLUMN [COLUMN...]]
                      Only show specified columns
  -n, --namespaces  [NAMESPACE [NAMESPACE...]]
                      Only show results from specified namespaces
  -x, --sort        [COLUMN]
                      Column to sort output on
  -f, --file        [FILE]
                      File to read instead of stdin.
EOF
)"
  
# Command line parsing
  if (( 1 )); then # FOLD Command line parsing
  local arg_help=0
  local arg_all_sources=0
  local arg_all_columns=0
  local arg_header_only=0
  local arg_source arg_sources=()
  local arg_column arg_columns=()
  local arg_column_start arg_column_starts=()
  local arg_column_width arg_column_widths=()
  local arg_namespace arg_namespaces=()
  local arg_sort
  local arg_file
  
  local active_arg
  local parse_args=1
  for arg in "$@"; do
    (( parse_args )) && [[ "${arg}" == "--" ]]   && parse_args=0 && continue
    (( ! parse_args )) && [[ "${arg}" == "++" ]] && parse_args=1 && continue
    if (( parse_args )) && [[ "${arg:0:1}" == "--" ]]; then
      [[ "${arg:2}" == "help" ]]        && arg_help=1        && continue
      [[ "${arg:2}" == "all-sources" ]] && arg_all_sources=1 && continue
      [[ "${arg:2}" == "all-columns" ]] && arg_all_columns=1 && continue
      [[ "${arg:2}" == "all" ]]         && arg_all_sources=1 \
                                        && arg_all_columns=1 && continue
      [[ "${arg:2}" == "header-only" ]] && arg_header_only=1 && continue
      
      [[ "${arg:2}" == "sources" ]]     && active_arg='sources'    && continue
      [[ "${arg:2}" == "columns" ]]     && active_arg='columns'    && continue
      [[ "${arg:2}" == "namespaces" ]]  && active_arg='namespaces' && continue
      [[ "${arg:2}" == "sort" ]]        && active_arg='sort'       && continue
      [[ "${arg:2}" == "file" ]]        && active_arg='file'       && continue
      echo "Commandline argument '${arg}' unrecognized." >&2 && return 1
    elif (( parse_args )) && [[ "${arg:0:1}" == "-" ]]; then
      for ((i=1; i<${#arg}; i++)); do
        [[ "${arg:$i:1}" == "?" ]] && arg_help=1        && continue
        [[ "${arg:$i:1}" == "h" ]] && arg_help=1        && continue
        [[ "${arg:$i:1}" == "S" ]] && arg_all_sources=1 && continue
        [[ "${arg:$i:1}" == "C" ]] && arg_all_columns=1 && continue
        [[ "${arg:$i:1}" == "A" ]] && arg_all_sources=1 \
                                   && arg_all_columns=1 && continue
        [[ "${arg:$i:1}" == "H" ]] && arg_header_only=1 && continue
        
        [[ "${arg:$i:1}" == "s" ]] && active_arg='sources'    && continue
        [[ "${arg:$i:1}" == "c" ]] && active_arg='columns'    && continue
        [[ "${arg:$i:1}" == "n" ]] && active_arg='namespaces' && continue
        [[ "${arg:$i:1}" == "x" ]] && active_arg='sort'       && continue
        [[ "${arg:$i:1}" == "f" ]] && active_arg='file'       && continue
        echo "Commandline argument '-${arg:$i:1}' unrecognized." >&2 && return 1
      done
    fi
    [[ "${active_arg}" == "sources" ]]    && arg_sources+=( "${arg}" )    && continue
    [[ "${active_arg}" == "columns" ]]    && arg_columns+=( "${arg}" )    && continue
    [[ "${active_arg}" == "namespaces" ]] && arg_namespaces+=( "${arg}" ) && continue
    [[ "${active_arg}" == "sort" ]]       && arg_sort="${arg}" && unset active_arg && continue
    [[ "${active_arg}" == "file" ]]       && arg_file="${arg}" && unset active_arg && continue
  done
  fi           # END FOLD Command line parsing
  (( arg_help )) && echo "${help_msg}" && return
  
# Argument validation and normalization
# <file>       Fetch and process input from file or stdin
  if (( 1 )); then
  local dlnum wgout="$(readfile "${arg_file:=default_file}")" || return 1
  if (( ! ${#wgout} )); then
    echo "Input file '${arg_file}' appears to not contain any data." >&2
    return 1
  fi
  wgout="$(echo "${wgout}" | sed -e 's/\r$//' -e 's/\r/\n/g' -e 's/…/_/g')"
  dlnum="$(( $(echo "${wgout}" | grep -n "^-\+$" | awk -F: '{print $1}') ))"
  wgout="$(echo "${wgout}" | tail -n "+$(( dlnum - 1 ))")"
  
  local lnhdr="$(echo "${wgout}" | head -n 1 | sed -e 's/\s*$//')"
  local lndiv="$(echo "${wgout}" | head -n 2 | tail -n 1 | sed -e 's/\s*$//')"
  local data=()
  for line in $(echo "${wgout}" | tail -n +3); do
    data+=( "${line}" )
  done
  
  local wgout_column wgout_columns=( ${lnhdr,,} )
  local wgout_column_width wgout_column_widths=()
  
  local n h x='\(^\|.*[^\s]\)' z='\([^\s].*\|$\)'
  for n in ${wgout_columns[@]}; do
    h="$(echo "$lnhdr" | sed -e "s/${x}\(${n}\s*\)${z}/\2/I")"
    wgout_column_widths+=( ${#h} )
  done
  (( wgout_column_widths[-1] += $(( ${#lndiv} - ${#lnhdr} )) ))
  fi           # END FOLD Fetch and process input from file or stdin

# <sources>    Parse and filter sources
  if (( 1 )); then
  if (( ! arg_all_sources )); then
    if (( ! ${#arg_sources[@]} )); then
      for default_source in ${default_sources[@]}; do
        arg_sources+=( "${default_source}" )
      done
    fi
    local i x=0 y
    for ((i=0; i<${#wgout_columns[@]}; i++)); do
      if [[ "${wgout_columns[$i],,}" == "source" ]]; then
        y="${wgout_column_widths[$i]}"
        break
      fi
      (( x += ${wgout_column_widths[$i]} ))
    done
    local src newdata=()
    for line in ${data[@]}; do
      src="$(echo "${line:$x:$y}" | sed -e 's/^\s*//' -e 's/\s*$//')"
      (( ! ${#src} )) && continue
      ! (echo "${arg_sources[@]}" | grep -iq "\b${src}\b") && continue
      newdata+=( "${line}" )
    done
    data=( ${newdata[@]} )
  fi
  fi           # END FOLD Parse and filter sources
  
# <namespaces> Parse and filter namespaces
  if (( 1 )); then
  if (( ! arg_all_namespaces )) && (( ${#arg_namespaces[@]} )); then
    local i x=0 y
    for ((i=0; i<${#wgout_columns[@]}; i++)); do
      if [[ "${wgout_columns[$i],,}" == "id" ]]; then
        y="${wgout_column_widths[$i]}"
        break
      fi
      (( x += ${wgout_column_widths[$i]} ))
    done
    local pkg_id newdata=()
    for line in ${data[@]}; do
      pkg_id="$(echo "${line:$x:$y}" | sed -e 's/^\s*//' -e 's/\s*$//')"
      for arg_namespace in ${arg_namespaces[@]}; do
        [[ "${pkg_id,,}" == "${arg_namespace,,}."* ]] && newdata+=( "${line}" )
      done
    done
    data=( ${newdata[@]} )
    unset newdata
  fi
  fi           # END FOLD Parse and filter namespaces
  
# <columns>    Parse columns
  if (( 1 )); then
  if (( ${#arg_columns[@]} )); then
    for arg_column in ${arg_columns[@]}; do
      if ! (echo "${wgout_columns[@]}" | grep -iq "\b${arg_column}\b"); then
        echo "Column '${arg_column}' does not exist." >&2
        return 1
      fi
    done
  else
    for default_column in ${default_columns[@]}; do
      if (echo "${wgout_columns[@]}" | grep -iq "\b${default_column}\b"); then
        arg_columns+=( "${default_column}" )
      fi
    done
  fi
  
  if (( arg_all_columns )); then
    for wgout_column in ${wgout_columns[@]}; do
      if ! (echo "${arg_columns[@]}" | grep -iq "\b${wgout_column}\b"); then
        arg_columns+=( "${wgout_column}" )
      fi
    done
  fi
  for arg_column in ${arg_columns[@]}; do
    arg_column_starts+=( 0 )
    arg_column_widths+=( 0 )
    for (( i=0; i<${#wgout_columns[@]} i++ )); do
      if [[ "${arg_column,,}" == "${wgout_columns[$1],,}" ]]; then
        (( arg_column_widths[-1] += ${wgout_column_widths[$i]} ))
        break
      fi
      (( arg_column_starts[-1] += ${wgout_column_widths[$i]} ))
    done
  done
  fi           # END FOLD Parse columns to show

# <sort>       Parse sort
  if (( 1 )); then
  if [[ -z "${arg_sort}" ]]; then
    arg_sort="${arg_columns[0]}"
  elif ! (echo "${wgout_columns[@]}" | grep -iq "\b${arg_sort}\b"); then
    echo "Column '${arg_sort}' is not available for sorting." >&2
    return 1
  fi
  
  local i x=0
  for ((i=0; i<${#wgout_columns[@]}; i++)); do
    [[ "${wgout_columns[$i],,}" == "$arg_sort,," ]] && break
    (( x += ${wgout_column_widths[$i]} ))
  done
  local newdata=( $(for line in "${data[@]}"; do echo "$line"; done | \
                    sort -k1,${x}) )
  data=( ${newdata[@]} )
  unset newdata
  fi # END FOLD Parse sort
  
# <columns>    Filter output to prior selected and parsed columns
  if (( 1 )); then
  local w=0
  for arg_column_width in ${arg_column_widths[@]}; do
    (( w += arg_column_width ))
  done
  for line in "$lnhdr" "$lndiv" ${data[@]}; do
    line="$(echo "${line}" | sed -e 's/\s*$//')"
    line+="$(repeat $(( w - ${#line} )))"
    for (( i=0; i<${#arg_columns[@]}; i++)); do
      echo -n "${line:${arg_column_starts[$i}:${arg_column_widths[$i]}}"
    done
    echo
  done
  fi # END FOLD Filter output to prior selected and parsed columns
}

alias winget="$(winpenv LOCALAPPDATA)/Microsoft/WindowsApps/winget.exe"
