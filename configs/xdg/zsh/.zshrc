ZINIT_DIR="$XDG_DATA_HOME/zinit"
ZINIT_HOME="$ZINIT_DIR/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    print -P "%F{160}Zinit is missing; run $DOTFILES/scripts/setup.sh.%f"
    return
fi

source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh"
ZINIT[ZCOMPDUMP_PATH]="$XDG_CACHE_HOME/zsh/zcompdump"

# Autosuggestions & fast-syntax-highlighting
zinit ice wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh-bd - https://github.com/Tarrasch/zsh-bd
zinit ice wait lucid
zinit light tarrasch/zsh-bd

# zsh-users/zsh-completions
zinit wait lucid light-mode for \
  as'completion' \
  atdelete'zinit cuninstall completions' \
  atload"zicompinit; zicdreplay" \
  atpull'zinit creinstall -q "$PWD"' \
  blockf \
  id-as'auto' \
  @zsh-users/zsh-completions

# zsh-autosuggestions
zinit ice wait lucid atload"!_zsh_autosuggest_start"
zinit load zsh-users/zsh-autosuggestions

# docker zsh completion
# https://github.com/kg8m/dotfiles/blob/a748a5b7ca05247aea17fff16af464e73c7919cc/.config/zsh/completion.zsh#L17
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \${PWD}" atpull"%atclone"
zinit light greymd/docker-zsh-completion

########## PROMPT
# Load version control information
autoload -Uz vcs_info
precmd() {
  vcs_info
  print -n -- $'\e[2 q'
}

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%b'

autoload -U colors && colors

NEWLINE=$'\n'
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[magenta]%}%M %{$fg[blue]%}%~%{$fg[red]%}]"
setopt PROMPT_SUBST
PS1+='%{$fg[green]%}[${vcs_info_msg_0_}]'
PS1+="${NEWLINE}%{$fg[green]%}$%b%{$reset_color%} "

########## PROMPT

# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache true


# https://superuser.com/questions/415650/does-a-fuzzy-matching-mode-exist-for-the-zsh-shell
# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

#emacs style keybindings
bindkey -e
[[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] &&
  source /usr/share/doc/fzf/examples/key-bindings.zsh
bindkey \^U backward-kill-line

#edit command in nvim
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Include hidden files in autocomplete:
_comp_options+=(globdots)

alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias q='exit'

# https://blog.confirm.ch/zsh-tips-changing-directories/
setopt auto_cd

# https://serverfault.com/questions/35312/unable-to-understand-the-benefit-of-zshs-autopushd
setopt autopushd

# https://unix.stackexchange.com/questions/331850/zsh-selects-a-pasted-text
unset zle_bracketed_paste

# 10ms for key sequences
KEYTIMEOUT=1

# https://unix.stackexchange.com/questions/48577/modifying-the-zsh-shell-word-split?rq=1
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

if [[ -t 0 && $- = *i* ]]
then
    stty -ixon
fi

HISTSIZE=999999999
SAVEHIST=999999999
HISTFILE="$XDG_STATE_HOME/zsh/history"
setopt BANG_HIST EXTENDED_HISTORY SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS
setopt HIST_VERIFY HIST_BEEP

_reject_sensitive_history() {
  setopt localoptions nocasematch
  local pattern='(^|[[:space:]])[^[:space:]]*(password|passwd|token|secret|api[-_]?key|private[-_]?key)[^[:space:]]*(=|[[:space:]])'
  [[ "$1" =~ $pattern ]] && return 1
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _reject_sensitive_history

if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r --disable-ai)"
fi

if [ -x "$(command -v workon)" ]; then
  alias workon=". =workon"
fi


alias ssh-copy-id='ssh-copy-id -i "$XDG_CONFIG_HOME/ssh/id_rsa"'
alias wget="wget --hsts-file=$XDG_CACHE_HOME/wget-hsts"

alias zkcd="cd $ZK_NOTEBOOK_DIR"

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

(( $+commands[mise] )) && eval "$(mise activate zsh)"




sonny-frame() {
  local screenshot="$1"
  local name="${screenshot:t}"

  if [[ ! "$name" =~ '^EP([0-9]{2})_([0-9]{2})-([0-9]{2})-([0-9]{2}\.[0-9]{3})\.(png|jpg)$' ]]; then
    print -u2 "Invalid screenshot name: $name"
    return 1
  fi

  local episode="$match[1]"
  local timestamp="$match[2]:$match[3]:$match[4]"
  local series="/home/evakuator/Shared/Sonny Boy [BD][1080p][HEVC 10bit x265][Dual Audio][Tenrai-Sensei]"
  local -a videos=("$series/Sonny Boy - $episode - "*.mkv(N))

  if (( ${#videos} != 1 )); then
    print -u2 "Expected one video for episode $episode; found ${#videos}"
    return 1
  fi

  mpv --pause --start="$timestamp" "$videos[1]"
}
