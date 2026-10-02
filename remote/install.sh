#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
SHELL_DIR="$CONF/terminal"
mkdir -p "$BIN" "$DATA" "$SHELL_DIR"

say() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$1"
  else
    echo "curl or wget is required" >&2
    exit 1
  fi
}

backup() {
  if [ -e "$1" ] && ! cmp -s "$1" "$2"; then
    cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

install_file() {
  local target="$1" tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  backup "$target" "$tmp"
  mv "$tmp" "$target"
}

append_once() {
  local file="$1" line="$2"
  touch "$file"
  grep -qxF "$line" "$file" || printf '\n%s\n' "$line" >>"$file"
}

if command -v starship >/dev/null 2>&1; then
  STARSHIP="$(command -v starship)"
elif [ -x "$BIN/starship" ]; then
  STARSHIP="$BIN/starship"
else
  say "Installing Starship in $BIN"
  fetch https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$BIN" >/dev/null
  STARSHIP="$BIN/starship"
fi

say "Writing $CONF/starship.toml"
"$STARSHIP" preset catppuccin-powerline |
  awk '
    NR == 1 { print; print ""; print "scan_timeout = 200"; print "command_timeout = 1000"; next }
    $0 == "$time\\" || /fg:sapphire bg:lavender/ { next }
    /\(fg:lavender\)/ && !/bold/ { sub(/fg:lavender/, "fg:sapphire") }
    $0 == "[time]" { in_time = 1; next }
    in_time && /^\[/ { in_time = 0 }
    in_time { next }
    $0 == "$username\\" { print; print "$hostname\\"; next }
    $0 == "show_notifications = true" { $0 = "show_notifications = false" }
    { print }
    END {
      print ""
      print "[hostname]"
      print "ssh_only = true"
      print "style = \"bg:red fg:crust\""
      print "format = \"[@$hostname]($style)\""
    }
  ' |
  install_file "$CONF/starship.toml"

if [ "$(uname -m)" != x86_64 ]; then
  say "No prebuilt binaries for $(uname -m), skipping eza and bat"
else
  if [ ! -x "$BIN/eza" ]; then
    say "Installing eza in $BIN"
    fetch https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz |
      tar -xz -C "$BIN" ./eza
  fi

  if [ ! -x "$BIN/bat" ]; then
    say "Installing bat in $BIN"
    bat_tag="$(fetch https://api.github.com/repos/sharkdp/bat/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
    bat_dir="bat-$bat_tag-x86_64-unknown-linux-musl"
    fetch "https://github.com/sharkdp/bat/releases/download/$bat_tag/$bat_dir.tar.gz" |
      tar -xz -C "$BIN" --strip-components=1 "$bat_dir/bat"
  fi
fi

if command -v bash >/dev/null 2>&1; then
  if [ ! -f "$DATA/blesh/ble.sh" ]; then
    if command -v xz >/dev/null 2>&1; then
      say "Installing ble.sh in $DATA/blesh"
      tmp="$(mktemp -d)"
      fetch https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar -xJ -C "$tmp"
      rm -rf "$DATA/blesh"
      mv "$tmp"/ble-nightly* "$DATA/blesh"
      rm -rf "$tmp"
    else
      say "xz is missing, skipping ble.sh (history suggestions); install xz-utils and run this again"
    fi
  fi
  if ! command -v ps >/dev/null 2>&1; then
    say "ps is missing, ble.sh stays off until procps is installed"
  fi

  install_file "$SHELL_DIR/terminal.bash" <<'BASH'
[[ $- == *i* ]] || return 0
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
[[ -n ${LANG-} ]] || export LANG=C.UTF-8
case "${LC_ALL:-${LC_CTYPE:-$LANG}}" in *[Uu][Tt][Ff]-8* | *[Uu][Tt][Ff]8*) ;; *) export LC_CTYPE=C.UTF-8 ;; esac
_blesh="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh"
if [[ -f $_blesh ]] && command -v ps >/dev/null 2>&1; then
  source "$_blesh"
fi
if [[ ${BLE_VERSION-} ]]; then
  bleopt complete_auto_delay=150
  bleopt complete_auto_complete_opts=syntax-disabled
  ble-face -s auto_complete fg=#6c7086
  ble-bind -f M-delete delete-forward-fword
  ble-bind -f M-BS delete-backward-fword
  ble-bind -f M-DEL delete-backward-fword
  ble-bind -f RET 'accept-line syntax'
  ble-bind -f C-m 'accept-line syntax'
fi
unset _blesh
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='ls -l --git'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never --style=plain'
__terminal_notify() {
  local code=$STARSHIP_CMD_STATUS title="Command finished on ${HOSTNAME%%.*}"
  [[ ${STARSHIP_START_TIME-} ]] || return 0
  (($(starship time) - STARSHIP_START_TIME >= 45000)) || return 0
  ((code == 0)) || title="Command failed ($code) on ${HOSTNAME%%.*}"
  printf '\e]777;notify;%s;%s\e\\' "$title" "$(fc -ln -1 | sed 's/^[[:space:]]*//')"
}
__terminal_precmd() {
  local dir=${PWD/#$HOME/\~}
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?5l'
  printf '\e]7;file://%s%s\e\\' "$HOSTNAME" "$PWD"
  printf '\e]2;%s %s\a' "${HOSTNAME%%.*}" "${dir##*/}"
  __terminal_notify
}
starship_precmd_user_func=__terminal_precmd
printf '\e]1337;SetUserVar=HOME=%s\a' "$(printf %s "$HOME" | base64 | tr -d '\n')"
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
BASH

  if [ ! -e "$HOME/.inputrc" ]; then
    install_file "$HOME/.inputrc" <<'INPUTRC'
$include /etc/inputrc
set completion-ignore-case on
set show-all-if-ambiguous on
set menu-complete-display-prefix on
set colored-stats on
set colored-completion-prefix on
"\e[A": history-search-backward
"\e[B": history-search-forward
TAB: menu-complete
"\e[Z": menu-complete-backward
INPUTRC
  fi

  append_once "$HOME/.bashrc" "[ -f \"$SHELL_DIR/terminal.bash\" ] && . \"$SHELL_DIR/terminal.bash\""
  if [ -f "$HOME/.bash_profile" ] && ! grep -q "bashrc" "$HOME/.bash_profile"; then
    append_once "$HOME/.bash_profile" "[ -f \"\$HOME/.bashrc\" ] && . \"\$HOME/.bashrc\""
  fi
fi

if command -v zsh >/dev/null 2>&1; then
  if [ ! -f "$DATA/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    say "Installing zsh-autosuggestions in $DATA/zsh-autosuggestions"
    tmp="$(mktemp -d)"
    fetch https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.tar.gz | tar -xz -C "$tmp"
    rm -rf "$DATA/zsh-autosuggestions"
    mv "$tmp"/zsh-autosuggestions-master "$DATA/zsh-autosuggestions"
    rm -rf "$tmp"
  fi

  install_file "$SHELL_DIR/terminal.zsh" <<'ZSH'
[[ -o interactive ]] || return 0
path=("$HOME/.local/bin" $path)
typeset -U path
autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
_zas="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f $_zas ]] && source "$_zas" && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
unset _zas
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[3;3~' kill-word
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='ls -l --git'
fi
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
__terminal_precmd() {
  local code=$? title="Command finished on ${HOST%%.*}"
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?5l'
  printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
  print -Pn '\e]2;%m %1~\a'
  (( ${+STARSHIP_START_TIME} )) || return 0
  (( $(starship time) - STARSHIP_START_TIME >= 45000 )) || return 0
  (( code == 0 )) || title="Command failed ($code) on ${HOST%%.*}"
  printf '\e]777;notify;%s;%s\e\\' "$title" "$(fc -ln -1)"
}
precmd_functions+=(__terminal_precmd)
printf '\e]1337;SetUserVar=HOME=%s\a' "$(printf %s "$HOME" | base64 | tr -d '\n')"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
ZSH
  append_once "$HOME/.zshrc" "[ -f \"$SHELL_DIR/terminal.zsh\" ] && . \"$SHELL_DIR/terminal.zsh\""
fi

say "Done. Open a new session (or run: exec \$SHELL -l) to see the new prompt."
