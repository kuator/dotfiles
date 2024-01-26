### Added by Zinit's installer
ZINIT_DIR="$XDG_DATA_HOME/zinit"
ZINIT_HOME="$ZINIT_DIR/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$ZINIT_DIR" && command chmod g-rwX "$ZINIT_DIR"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk


# Autosuggestions & fast-syntax-highlighting
zinit ice wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh-autosuggestions
zinit ice wait lucid atload"!_zsh_autosuggest_start"
zinit load zsh-users/zsh-autosuggestions

# zsh-bd - https://github.com/Tarrasch/zsh-bd
zinit ice wait lucid
zinit light tarrasch/zsh-bd

# zsh-users/zsh-completions
zinit light zsh-users/zsh-completions

# zsh-users/zsh-completions
zinit light chr-fritz/docker-completion.zshplugin

zinit ice wait'0b' lucid id-as"junegunn/fzf_completions" pick"/dev/null" \
  multisrc"shell/{completion,key-bindings}.zsh"
zinit light junegunn/fzf

# FZF
zinit ice from="gh-r" as="command" bpick="*linux_amd64*"
zinit light junegunn/fzf

# BurntSushi/ripgrep
zinit ice as"command" from"gh-r" mv"ripgrep* -> rg" pick"rg/rg"
zinit light BurntSushi/ripgrep

# LAZYGIT
zinit ice lucid wait="0" as="program" from="gh-r" bpick="*Linux_x86_64*" pick="lazygit"
zinit light jesseduffield/lazygit

# LAZYDOCKER
zinit ice lucid wait="0" as="program" from="gh-r" bpick="*Linux_x86_64*" pick="lazydocker"
zinit light jesseduffield/lazydocker

# fdfind
zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

#stylua
zinit wait'1b' lucid light-mode from'gh-r' as'command' bpick'*linux*.tar.gz' for \
    bpick'*linux.zip' JohnnyMorganz/StyLua \

# shfmt
zinit ice from"gh-r" as"program" mv"shfmt* -> shfmt" fbin"shfmt"
zinit light mvdan/sh

zinit ice wait"0a" as"command" from"gh-r" lucid \
  mv"zoxide*/zoxide -> zoxide" \
  atclone"./zoxide init zsh > init.zsh" \
  atpull"%atclone" src"init.zsh" nocompile'!'
zinit light ajeetdsouza/zoxide


# zinit ice wait'0' lucid
# zinit snippet 'https://github.com/git/git/contrib/completion/git-prompt.sh'

### asdf-vm
zinit wait lucid as"null" \
    from"github" src"asdf.sh" as"program" for \
    @asdf-vm/asdf

zinit ice lucid wait'1' from"gh-r" as"program" mv"direnv* -> direnv" \
    atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
    pick"direnv" src="zhook.zsh" for \
        direnv/direnv

# it also works with turbo mode:
zinit ice wait lucid
zinit load redxtech/zsh-asdf-direnv

# docker zsh completion
# https://github.com/kg8m/dotfiles/blob/a748a5b7ca05247aea17fff16af464e73c7919cc/.config/zsh/completion.zsh#L17
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \${PWD}" atpull"%atclone"
zinit light greymd/docker-zsh-completion

zinit ice wait lucid as"completion"
zinit snippet https://github.com/asdf-vm/asdf/blob/master/completions/_asdf

########## PROMPT
# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

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
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

if [[ -t 0 && $- = *i* ]]
then
    stty -ixon
fi 

# https://gist.github.com/matthewmccullough/787142
# https://unix.stackexchange.com/questions/273861/unlimited-history-in-zsh
# HISTFILE="$HOME/.zsh_history"
HISTSIZE=999999999              #How many lines of history to keep in memory
SAVEHIST=999999999              #Number of history entries to save to disk
HISTFILE=$ZDOTDIR/.zsh_history   #Where to save history to disk
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

countdown

compinit -d $XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}

# https://github.com/zdharma-continuum/zinit#quick-start maybe?
# SSH
alias ssh="ssh $SSH_CONFIG $SSH_ID "
alias ssh-copy-id="ssh-copy-id $SSH_ID"
alias wget="wget --hsts-file="$XDG_CACHE_HOME/wget-hsts""


if [ -x "$(command -v workon)" ]; then
  alias workon=". =workon"
fi

if [ -x "$(command -v venve)" ]; then
  alias venve=". =venve"
fi

alias zkcd="cd $ZK_NOTEBOOK_DIR"
alias cs="coursier"

source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
