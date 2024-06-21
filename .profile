# Very interesting stackexchange question
# https://unix.stackexchange.com/questions/552459/why-does-lightdm-source-my-profile-even-though-my-login-shell-is-zsh
# Very interesting stackexchange question


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

# RUST
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
# https://github.com/rememberYou/dotfiles/blob/master/sh/.config/sh/xdg#L23
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PATH=$PATH:${CARGO_HOME:-~/.cargo}/bin

if [ -d "$CARGO_HOME" ] ; then
    . $CARGO_HOME/env
fi


# ASDF
# --------------------------------------------

# DENO
# https://deno.land/manual/getting_started/setup_your_environment
export DENO_INSTALL_ROOT=$XDG_DATA_HOME/bin

# GOLANG
export GOPATH="$HOME/dev/go/libs"
export PATH="$PATH:$GOPATH/bin"
export GOPATH="$GOPATH:$HOME/dev/go/code"

# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
export ASDF_CONFIG_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DIR="$OPT/asdf"
export ASDF_CONFIG_FILE="$ASDF_CONFIG_DIR/asdfrc"
# export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG_DIR/tool-versions"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG_DIR/tool-versions"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

if [ -f $OPT/asdf/asdf.sh ]; then
  . $OPT/asdf/asdf.sh
fi

# ----------------------------------------------


# if [ -f $OPT/asdf/asdf.sh ]; then
#   asdf_update_dotnet_home() {
#     dotnet_path="$(asdf which dotnet)"
#     if [[ -n "${dotnet_path}" ]]; then
#       export DOTNET_ROOT
#       DOTNET_ROOT="$(dirname "$(realpath "${dotnet_path}")")"
#       export MSBuildSDKsPath
#       DOTNET_VERSION="$(dotnet --version)"
#       export MSBuildSDKsPath="$DOTNET_ROOT/sdk/$DOTNET_VERSION/Sdks"
#       export DOTNET_CLI_TELEMETRY_OPTOUT=1
#       export DOTNET_CLI_HOME="${XDG_DATA_HOME}/dotnet-$DOTNET_VERSION";
#       export PATH="$PATH:$DOTNET_CLI_HOME/.dotnet/tools"
#     fi
#   }
#   
#   asdf_update_dotnet_home
# fi


# Nuget
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages

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

export NVIM_APPNAME="nvim"

# https://jorengarenar.github.io/blog/vim-xdg
export VIMINIT="if has('nvim') | so ${XDG_CONFIG_HOME:-$HOME/.config}/$NVIM_APPNAME/init.lua | else | set nocp | so ${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc | endif"

# RUBY
export GEM_HOME="$XDG_CACHE_HOME/gems"
export PATH="$GEM_HOME/bin:$PATH"

# RUFF
export RUFF_CACHE_DIR="$XDG_CACHE_HOME/ruff"

# JAVA CLASSPATH
export CLASSPATH=.

# JAVA FONTS XDG
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker 

#zettelkasten
export ZK_NOTEBOOK_DIR="${HOME}/dev/personal/zettelkasten"
# export ZK_NOTEBOOK_DIR=~/dev/personal/zettelkasten
mkdir -p $ZK_NOTEBOOK_DIR

export POETRY_CACHE_DIR=$XDG_CACHE_HOME/pypoetry
export POETRY_VIRTUALENVS_PATH=$XDG_CACHE_HOME/virtualenvs

# less
export LESSHISTFILE="$XDG_STATE_HOME"/less/history

# omnisharp
export OMNISHARPHOME="$XDG_CONFIG_HOME/omnisharp"

mkdir -p /tmp/tmp
