#!/bin/bash

export DOTFILES="$HOME/dotfiles"
export XDG_CONFIG_HOME="$HOME/.config"

mkdir -p $XDG_CONFIG_HOME/VSCodium/User
ln -sv $DOTFILES/codium/keybindings.json $XDG_CONFIG_HOME/VSCodium/User/keybindings.json
ln -sv $DOTFILES/codium/settings.json $XDG_CONFIG_HOME/VSCodium/User/settings.json
