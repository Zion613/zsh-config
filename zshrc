#---------------- Zshrc ARCHLINUX - CONFIGURATION  ----------------
export TERM=xterm-256color

#---------------- History ----------------
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

#---------------- Prompt -----------------------------
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

#---------------- Keybindings ----------------
bindkey -e
bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history

#---------------- Plugins  ------------------------------------------
# NOTE: zsh-autocomplete disabled (caused freezes + ZLE warnings)
# [[ -r /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] && \
#   source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# zsh-autosuggestions (async, light)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#AAAAAA,bold"
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting (keep last)
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# GRC
[[ -s "/etc/profile.d/grc.zsh" ]] && source /etc/profile.d/grc.zsh
files=(
  /etc/grc.zsh
  /usr/local/etc/grc.zsh
  /usr/share/grc/grc.zsh
)
for file in $files; do
  [[ -r "$file" ]] && source "$file" && break
done
unset file files

#---------------- Aliases ----------------
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias tree="tree -C"
alias cat="ccat"

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
    local realcmd="${${(z)aliases[$cmd]}[1]:-$cmd}"
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

#---------------- Completion (cached + lightweight menu) ----------------
zstyle ':completion*' completer _complete _ignored _approximate _sudo
zstyle ':completion*' sudo 'yes'
zstyle ':completion:*' list-colors '=*=90'
zstyle ':completion:*:*:sudo:*' command-path /usr/bin

# Lightweight built-in completion menu (less heavy than zsh-autocomplete)
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

autoload -Uz compinit
mkdir -p ~/.cache/zsh
compinit -d ~/.cache/zsh/zcompdump -C

#---------------- Colorize man pages ----------------
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;33m'
export LESS_TERMCAP_so=$'\e[01;44;37m'
export LESS_TERMCAP_us=$'\e[01;37m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export GROFF_NO_SGR=1
