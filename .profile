# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$HOME/.config/zsh"
export BROWSER=firefox
export EDITOR=nvim
export OPT="$HOME/opt"
export DOTFILES=$HOME/dotfiles
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

# https://github.com/npm/npm/issues/6675#issuecomment-251049832
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/config
export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm

export SUDO_ASKPASS=/usr/bin/ssh-askpass

# export RUSTUP_HOME=/opt/rust/rustup
# export CARGO_HOME=/opt/rust/cargo
# . "/opt/rust/cargo/env"

# ASDF
# --------------------------------------------
# RUST
# https://github.com/rememberYou/dotfiles/blob/master/sh/.config/sh/xdg#L23
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PATH=$PATH:${CARGO_HOME:-~/.cargo}/bin

# DENO
# https://deno.land/manual/getting_started/setup_your_environment
export DENO_INSTALL_ROOT=$XDG_DATA_HOME/bin

# DENO
export GOPATH="$HOME/dev/go/libs"
export PATH="$PATH:$GOPATH/bin"
export GOPATH="$GOPATH:$HOME/dev/go/code"

# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
export ASDF_CONFIG_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DIR="$OPT/asdf"
export ASDF_CONFIG_FILE="$ASDF_CONFIG_DIR/asdfrc"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG_DIR/tool-versions"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

if [ -f $OPT/asdf/asdf.sh ]; then
  . $OPT/asdf/asdf.sh
fi
# ----------------------------------------------

# ssh
# https://superuser.com/a/874924
if [ -s "${XDG_CONFIG_HOME}/ssh/config" ]
then
    export SSH_CONFIG="-F ${XDG_CONFIG_HOME}/ssh/config"
fi
if [ -s "${XDG_CONFIG_HOME}/ssh/id_dsa" ]
then
    export SSH_ID="-i ${XDG_CONFIG_HOME}/ssh/id_dsa"
fi

export PYTHONSTARTUP="${XDG_CONFIG_HOME:-$HOME/.config}/pythonstartup.py"

export PSQLRC="$XDG_CONFIG_HOME/pg/psqlrc"
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export PGPASSFILE="$XDG_CONFIG_HOME/pg/pgpass"
export PGSERVICEFILE="$XDG_CONFIG_HOME/pg/pg_service.conf"

mkdir -p "$XDG_CONFIG_HOME/pg" && mkdir -p "$XDG_STATE_HOME"

# >>> coursier install directory >>>
export PATH="$PATH:$XDG_DATA_HOME/coursier/bin"
# <<< coursier install directory <<<

export VIMINIT="if has('nvim') | so ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua | else | set nocp | so ${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc | endif"
