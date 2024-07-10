_log() {
  # Do the actual logging here.
  local levels_logger=( debug info notice warning err crit alert emerg )
  local levels_display=( 'debug    ' 'info     ' 'notice   ' 'Warning  ' 'Error    ' 'CRITICAL ' 'ALERT    ' 'EMERGENCY' )
  local level="${1}"
  local tag="${2}(${3})"
  local args=()
  args+=( '--priority' )
  args+=( "user.${levels_logger[level]}" )
  args+=( '--tag' )
  args+=( "${tag}" )
  (( ${level} >= ${JOURNAL_VERBOSITY:-2} )) && logger "${args[@]}" -- "[ ${levels_display[level]^^} ] ${4}"
  (( ${level} >= ${SHELL_VERBOSITY:-1} )) && logger "${args[@]}" --stderr --no-act -- "[ ${levels_display[level]} ] ${4}"
}

caller() {
  local n="${1:-1}"
  if (( $# > 1 )) || [[ ! "${n}" =~ ^[1-9][0-9]*$ ]]; then
    local priority='user.crit'
    logger -p user.crit
  && echo "Function 'caller' optionally accepts one integer argument larger or equal to 1, not '${n}'." >&2 \
  && return 1
  
  
}

log() {
}

debug() {
}

