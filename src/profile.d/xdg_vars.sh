XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
XDG_LIBRARY_HOME="${XDG_LIBRARY_HOME:-${HOME}/.local/lib}"
XDG_BINARY_HOME="${XDG_BINARY_HOME:-${HOME}/.local/bin}"

if [ ! -d "${XDG_CONFIG_HOME}" ]; then
  for d in "${HOME}/.xdg/etc" "${HOME}/.local/etc" "${HOME}/.etc"; do
    [ -d "${d}" ] && XDG_CONFIG_HOME="${d}" && break
  done
fi
if [ ! -d "${XDG_DATA_HOME}" ]; then
  for d in "${HOME}/.xdg/share" "${HOME}/.share"; do
    [ -d "${d}" ] && XDG_DATA_HOME="${d}" && break
  done
fi
if [ ! -d "${XDG_STATE_HOME}" ]; then
  for d in "${HOME}/.xdg/state" "${HOME}/.state"; do
    [ -d "${d}" ] && XDG_STATE_HOME="${d}" && break
  done
fi
if [ ! -d "${XDG_CACHE_HOME}" ]; then
  for d in "${HOME}/.xdg/cache" "${HOME}/.local/cache"; do
    [ -d "${d}" ] && XDG_CACHE_HOME="${d}" && break
  done
fi
if [ ! -d "${XDG_LIBRARY_HOME}" ]; then
  for d in "${HOME}/.xdg/lib" "${HOME}/.lib"; do
    [ -d "${d}" ] && XDG_LIBRARY_HOME="${d}" && break
  done
fi
if [ ! -d "${XDG_BINARY_HOME}" ]; then
  for d in "${HOME}/.xdg/bin" "${HOME}/.bin"; do
    [ -d "${d}" ] && XDG_BINARY_HOME="${d}" && break
  done
fi

[ -n "${XDG_CONFIG_HOME}" && -d "${XDG_CONFIG_HOME}" ] \
&& export XDG_CONFIG_HOME || unset XDG_CONFIG_HOME
[ -n "${XDG_DATA_HOME}" && -d "${XDG_DATA_HOME}" ] \
&& export XDG_DATA_HOME || unset XDG_DATA_HOME
[ -n "${XDG_STATE_HOME}" && -d "${XDG_STATE_HOME}" ] \
&& export XDG_STATE_HOME || unset XDG_STATE_HOME
[ -n "${XDG_CACHE_HOME}" && -d "${XDG_CACHE_HOME}" ] \
&& export XDG_CACHE_HOME || unset XDG_CACHE_HOME
[ -n "${XDG_LIBRARY_HOME}" && -d "${XDG_LIBRARY_HOME}" ] \
&& export XDG_LIBRARY_HOME || unset XDG_LIBRARY_HOME
[ -n "${XDG_BINARY_HOME}" && -d "${XDG_BINARY_HOME}" ] \
&& export XDG_BINARY_HOME || unset XDG_BINARY_HOME
