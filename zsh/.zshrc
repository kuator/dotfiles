#https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
source /usr/share/git/completion/git-prompt.sh
autoload -U colors && colors
NEWLINE=$'\n'
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[magenta]%}%M %{$fg[blue]%}%~%{$fg[red]%}]"
setopt PROMPT_SUBST
PS1+='%{$fg[green]%}[$(__git_ps1 "%s")]'
PS1+="${NEWLINE}%{$fg[green]%}$%b%{$reset_color%} "

autoload -U compinit
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# https://superuser.com/questions/415650/does-a-fuzzy-matching-mode-exist-for-the-zsh-shell
# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

zmodload zsh/complist
compinit

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
alias sf='z'
alias emacs='emacs -nw'

#https://gist.github.com/matthewmccullough/787142
HISTSIZE=5000               	#How many lines of history to keep in memory
HISTFILE=$ZDOTDIR/.zsh_history  #Where to save history to disk
SAVEHIST=5000               	#Number of history entries to save to disk
HISTDUP=erase              	#Erase duplicates in the history file
setopt    appendhistory     	#Append history to the history file (no overwriting)
setopt    sharehistory      	#Share history across terminals
setopt    incappendhistory  	#Immediately append to the history file, not just when a term is killed

# https://blog.confirm.ch/zsh-tips-changing-directories/
setopt auto_cd

#fzf keybindings
source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh

#z.lua
eval "$(lua /opt/z.lua/z.lua --init zsh)"
export _ZL_HYPHEN=1
export _ZL_DATA=$XDG_CONFIG_HOME/zlua/zlua

#https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
source /opt/zsh-autosuggestions/zsh-autosuggestions.zsh

# https://github.com/Tarrasch/zsh-bd
source /opt/zsh-bd/bd.zsh

# https://github.com/zsh-users/zsh-syntax-highlighting
source /opt/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# http://info2html.sourceforge.net/cgi-bin/info2html-demo/info2html?(zsh)Movement
# bindkey '[' vi-rev-repeat-find
# bindkey ']' vi-repeat-find
# 10ms for key sequences
KEYTIMEOUT=1

# https://unix.stackexchange.com/questions/48577/modifying-the-zsh-shell-word-split?rq=1
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
