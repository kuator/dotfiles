# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$HOME/.config/zsh"
export BROWSER=firefox
export EDITOR=nvim
export OPT="$HOME/opt"
export DOTFILES=$HOME/dotfiles

# https://github.com/npm/npm/issues/6675#issuecomment-251049832
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/config
export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm

export SUDO_ASKPASS=/usr/bin/ssh-askpass

# export RUSTUP_HOME=/opt/rust/rustup
# export CARGO_HOME=/opt/rust/cargo
# . "/opt/rust/cargo/env"

# export GOPATH="~/golib"
# export PATH="$PATH:$GOPATH/bin"
# export GOPATH="$GOPATH:~/gofolder"

# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
export ASDF_CONFIG_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DIR="$OPT/asdf"
export ASDF_CONFIG_FILE="$ASDF_CONFIG_DIR/asdfrc"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG_DIR/tool-versions"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

if [ -f $OPT/asdf/asdf.sh ]; then
  . $OPT/asdf/asdf.sh
fi

# ssh
# https://superuser.com/a/874924
if [ -s "${XDG_CONFIG_HOME}/ssh/config" ]
then
    SSH_CONFIG="-F ${XDG_CONFIG_HOME}/ssh/config"
fi
if [ -s "${XDG_CONFIG_HOME}/ssh/id_dsa" ]
then
    SSH_ID="-i ${XDG_CONFIG_HOME}/ssh/id_dsa"
fi
