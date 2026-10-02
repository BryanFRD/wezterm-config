[[ $- == *i* ]] || return 0

export USER=${USER:-$USERNAME}

[[ -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --attach=none

__terminal_notify() {
  local code=$STARSHIP_CMD_STATUS title="Command finished"
  [[ ${STARSHIP_START_TIME-} ]] || return 0
  (($(starship time) - STARSHIP_START_TIME >= 45000)) || return 0
  ((code == 0)) || title="Command failed ($code)"
  printf '\e]777;notify;%s;%s\e\\' "$title" "$(fc -ln -1 | sed 's/^[[:space:]]*//')"
}

__terminal_precmd() {
  local dir=${PWD/#$HOME/\~}
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?5l'
  printf '\e]7;file://%s/%s\e\\' "$HOSTNAME" "$(cygpath -m "$PWD")"
  printf '\e]2;%s\a' "${dir##*/}"
  __terminal_notify
}
starship_precmd_user_func=__terminal_precmd
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

if [[ ${BLE_VERSION-} ]]; then
  bleopt complete_auto_delay=150
  bleopt complete_auto_complete_opts=syntax-disabled
  ble-face -s auto_complete fg=#6c7086
  ble-bind -f M-delete delete-forward-fword
  ble-bind -f M-BS delete-backward-fword
  ble-bind -f M-DEL delete-backward-fword
  ble-bind -f RET 'accept-line syntax'
  ble-bind -f C-m 'accept-line syntax'
  ble-attach
fi
