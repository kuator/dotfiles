ZSH_DATA=$XDG_DATA_HOME/zsh

[[ -f $XDG_DATA_HOME/zsh/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git $XDG_DATA_HOME/zsh/zsh-snap

source $XDG_DATA_HOME/zsh/zsh-snap/znap.zsh

znap source zsh-users/zsh-autosuggestions
# znap source zsh-users/zsh-syntax-highlighting
znap source zdharma-continuum/fast-syntax-highlighting
znap source Tarrasch/zsh-bd
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
znap source git/git contrib/completion/git-prompt.sh
znap source junegunn/fzf shell/{completion,key-bindings}.zsh
# direnv hooked into asdf
# znap eval asdf-community/asdf-direnv "asdf exec $(asdf which direnv) hook zsh"
# Better cding like z.lua but faster
znap eval zoxide 'zoxide init zsh'
# source /opt/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# https://github.com/momo-lab/zsh-abbrev-alias

# install fzf dynamically, maybe?
# (( ${+commands[fzf]} )) || ~[fzf]/install --bin

# Use ~[dynamically-named dirs] to add repos to your $path or $fpath.
# Znap will download them automatically.
fpath+=(
    ~[asdf-vm/asdf]/completions
    ~[asdf-community/asdf-direnv]/completions
)

autoload -U colors && colors

NEWLINE=$'\n'
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[magenta]%}%M %{$fg[blue]%}%~%{$fg[red]%}]"
setopt PROMPT_SUBST
PS1+='%{$fg[green]%}[$(__git_ps1 "%s")]'
PS1+="${NEWLINE}%{$fg[green]%}$%b%{$reset_color%} "

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

# https://github.com/zdharma-continuum/zinit#quick-start maybe?
# SSH
alias ssh="ssh $SSH_CONFIG $SSH_ID "
alias ssh-copy-id="ssh-copy-id $SSH_ID"
