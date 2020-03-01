export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/nvim
export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/firefox
export ZDOTDIR="$HOME/.config/zsh"
export WGETRC="$HOME/.config/wget/wgetrc"
export INPUTRC="$HOME/.config/inputrc"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export PATH=$PATH:$HOME/.local/bin
export VIMINIT='if !has("nvim") | let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | else | let $MYVIMRC="$XDG_CONFIG_HOME/nvim/init.vim" | endif | source $MYVIMRC'

# pipenv: change virtualenvs location 
export WORKON_HOME=/opt/.venvs
export CDPATH=".:~/Documents/Unity/shit:~"

# https://github.com/rust-lang/rustup/issues/618
export CARGO_HOME=/opt/.cargo
export RUSTUP_HOME=/opt/.rust
export PATH=$PATH:/opt/.cargo/bin

# https://superuser.com/questions/874901/what-are-the-step-to-move-all-your-dotfiles-into-xdg-directories
# gnupg
export GNUPGHOME=${XDG_CONFIG_HOME}/gnupg
# ICEauthority
export ICEAUTHORITY=${XDG_CACHE_HOME}/ICEauthority
# less
export LESSHISTFILE="${XDG_CONFIG_HOME}/less/history"
export LESSKEY="${XDG_CONFIG_HOME}/less/keys"
# mplayer
export MPLAYER_HOME=$XDG_CONFIG_HOME/mplayer
# subversion
export SUBVERSION_HOME=$XDG_CONFIG_HOME/subversion
# ssh
if [ -s "${XDG_CONFIG_HOME}/ssh/config" ]
then
    SSH_CONFIG="-F ${XDG_CONFIG_HOME}/ssh/config"
fi
if [ -s "${XDG_CONFIG_HOME}/ssh/id_dsa" ]
then
    SSH_ID="-i ${XDG_CONFIG_HOME}/ssh/id_dsa"
fi

#pyenv scripts
export PYENV_ROOT="/opt/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

#nvm stuff
export NVM_DIR="/opt/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" # This loads nvm

export PATH="/opt/.cargo/bin:$PATH"

# https://github.com/npm/npm/issues/6675#issuecomment-251049832
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/config
export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
