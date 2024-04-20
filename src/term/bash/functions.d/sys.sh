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
  done
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
