#!/bin/bash

export XDG_DATA_HOME="$HOME/.local/share"

cd /tmp

if [ ! -f UbuntuMono.zip ]; then
  wget 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/UbuntuMono.zip'
  unzip UbuntuMono.zip -d $XDG_DATA_HOME/fonts
  fc-cache -fv
fi

cd -
