XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
if [ ! -d "${XDG_CONFIG_HOME}" ]; then
  for d in "${HOME}/.xdg/etc" "${HOME}/.local/etc" "${HOME}/.etc"; do
    [ -d "${d}" ] || continue
    XDG_CONFIG_HOME="${d}"
    break
  done
fi


export XDG_CONFIG_HOME
export XDG_DATA_HOME
export XDG_STATE_HOME
export XDG_CACHE_HOME
export XDG_LIBRARY_HOME
export XDG_BINARY_HOME
