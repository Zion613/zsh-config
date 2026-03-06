#---------------- Zshrc ARCHZION - VERSIONE COMPLETA OTTIMIZZATA (GRIGIO) ----------------
export TERM=xterm-256color

#---------------- History ----------------
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

#---------------- Prompt Model 4 (sicuro) ----------------
get_distro() {
    if [[ -r /etc/os-release ]]; then
        source /etc/os-release
        echo "${NAME:-UnknownOS}"
    else
        echo "UnknownOS"
    fi
}

if [[ $EUID -eq 0 ]]; then
  SYMBOL="◆"
  USER_COLOR="%{%F{red}%}"
else
  SYMBOL="◇"
  USER_COLOR="%{%F{magenta}%}"
fi

PROMPT="%{%B%F{blue}%}╭─ ${USER_COLOR}%n %{%F{cyan}%}${SYMBOL}%{%F{blue}%} %m %{%F{white}%}[$(get_distro)]%{%f%b%}
%{%F{blue}%}│  %{%F{yellow}%}%~%{%f%}
%{%F{blue}%}╰─%{%F{green}%}$%{%f%} "

#---------------- Bindkey delete-char (completo) ----------------
delete_keys=(
  "^[[3~" "^[[1;5A" "^[[1;5B" "^[[1;5C" "^[[1;5D"
  "^[[27;5;65457~" "^[[27;5;65465~" "^[[27;5;49~"
  "^_" "^[[27;5;57~" "^[[27;5;39~" "^[[27;5;236~"
  "^[[27;7;49~" "^[[27;7;57~" "^[[27;5;232~" "^[" "^[[27;5;232~"
  "^[[27;5;242~" "^[[27;5;224~" "^[[27;5;249~" "^[[27;5;44~" "^[[27;5;46~"
  "^[[27;6;33~" "^[[27;6;34~" "^[[27;6;163~" "^[[27;6;36~" "^[[27;6;37~"
  "^[[27;6;38~" "^[[27;6;40~" "^[[27;6;41~" "^[[27;7;48~" "^[[27;7;232~"
  "^[[27;7;43~" "^[[27;7;242~" "^[[27;7;224~" "^[[27;7;249~" "^[[27;7;44~"
  "^[[27;7;46~" "^[[27;7;45~" "^[[27;7;60~" "^[[27;5;60~" "^[," "^[[1;3D"
  "^[[1;3C" "^[[1;3A" "^[ì" "^['" "^s" "^[[1;3A" "^[[A" "^[[1;2A" "^[[1;2D"
  "^[[1;2B" "^[[1;2C" "^[[1;7D" "^[[1;7B" "^[[1;7C" "^[[1;7A" "^[[1;6D" "^[[1;6B"
  "^[[1;6C" "^[[1;6A" "^[[1;4D" "^[[1;4B" "^[[1;4B" "^[[1;4A" "^[[5~" "^[[6~"
  "^[[F" "^[[2~" "^[[3~" "^[[1;5P" "^[[1;5Q" "^[[1;5R" "^[[1;5S" "^[[15;5~"
  "^[[17;5~" "^[[18;5~" "^[[19;5~" "^[[20;5~" "^[[21;5~" "^[[23;5~" "^[[24;5~"
  "^[[2;5~" "^[[2;7~" "^[[3;5~" "^[[3;7~" "^[[1;5H" "^[[5;5~" "^[[1;5F" "^[[6;5~"
  "^[[1;3P" "^[[1;3Q" "^[[1;3R" "^[[15;3~" "^[[17;3~" "^[[18;3~" "^[[19;3~"
  "^[[20;3~" "^[[21;3~" "^[[23;3~" "^[[24;3~"
)

for k in "${delete_keys[@]}"; do
  bindkey "$k" delete-char
done

#---------------- Plugins (ordine ottimizzato) ----------------
# 1. zsh-autocomplete
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# 2. zsh-autosuggestions (grigio soft)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#AAAAAA,bold"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# 3. zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 4. GRC
[[ -s "/etc/profile.d/grc.zsh" ]] && source /etc/profile.d/grc.zsh
files=(
  /etc/grc.zsh
  /usr/local/etc/grc.zsh
  /opt/homebrew/etc/grc.zsh
  /home/linuxbrew/.linuxbrew/etc/grc.zsh
  /usr/share/grc/grc.zsh
)
for file in $files; do
  [[ -r "$file" ]] && source "$file" && break
done
unset file files

#---------------- Aliases ----------------
alias ls="ls --color=always"
alias cat="ccat"
alias grep="grep --color=always"
alias tree="tree -C"

#---------------- Sudo command-line widget ----------------
__sudo-replace-buffer() {
  local old=$1 new=$2 space=${2:+ }
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}

sudo-command-line() {
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi
  {
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
        sudo\ *)    __sudo-replace-buffer "sudo" "" ;;
        *)          LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi
    local cmd="${${(z)BUFFER}[1]}"
    local realcmd="${${(z)aliases[$cmd]}[1]:-$cmd]}"
    local editorcmd="${${(z)EDITOR}[1]}"
    if [[ "$realcmd" = "$editorcmd" ]] || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      __sudo-replace-buffer "$cmd" "sudo -e"
      return
    fi
    case "$BUFFER" in
      "$editorcmd"* | "$EDITOR"*) __sudo-replace-buffer "$cmd" "sudo -e" ;;
      sudo\ -e\ *)                __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
      sudo\ *)                     __sudo-replace-buffer "sudo" "" ;;
      *)                           LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    LBUFFER="${WHITESPACE}${LBUFFER}"
    zle && zle redisplay
  }
}

zle -N sudo-command-line
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

#---------------- Completion ----------------
zstyle ':completion*' completer _complete _ignored _approximate _sudo
zstyle ':completion*' sudo 'yes'
zstyle ':completion:*'  list-colors '=*=90'
zstyle ':completion:*:*:sudo:*' command-path /usr/bin
autoload -U compinit && compinit

#---------------- Colorize man pages ----------------
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;33m'
export LESS_TERMCAP_so=$'\e[01;44;37m'
export LESS_TERMCAP_us=$'\e[01;37m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export GROFF_NO_SGR=1
