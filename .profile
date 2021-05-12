# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$HOME/.config/zsh"
export BROWSER=/usr/bin/firefox
export EDITOR=/usr/bin/nvim
#export VISUAL=/usr/bin/nvim


# https://github.com/rust-lang/rustup/issues/618
export CARGO_HOME=/opt/.cargo
export RUSTUP_HOME=/opt/.rust
export PATH=$PATH:/opt/.cargo/bin
export PATH=$PATH:/opt/bin

# pipenv: change virtualenvs location 
export WORKON_HOME=/opt/.venvs
# export CDPATH=".:~/Documents/Unity/shit:~"

# pyenv scripts
export PYENV_ROOT="/opt/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

#nvm stuff
export NVM_DIR="/opt/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" # This loads nvm


# https://github.com/npm/npm/issues/6675#issuecomment-251049832
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/config
export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm

export NOTES_DIRECTORY='/opt/notes'

#fuck microsoft
export DOTNET_CLI_TELEMETRY_OPTOUT=1

#fuck java
export JAVA_HOME=/opt/jdk-14.0.2
export PATH=$JAVA_HOME/bin:$PATH

#scala
export PATH=/opt/scala-2.13.3/bin:$PATH

#sbt
export PATH=/opt/sbt/bin:$PATH

#haskell
export PATH=/opt/ghc/bin:$PATH
