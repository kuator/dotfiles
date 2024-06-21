#!/bin/bash

export ASDF_DIR="$OPT/asdf"
# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
export ASDF_CONFIG_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DIR="$OPT/asdf"
export ASDF_CONFIG_FILE="$ASDF_CONFIG_DIR/asdfrc"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG_DIR/tool-versions"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

if [ -f $OPT/asdf/asdf.sh ]; then
  . $OPT/asdf/asdf.sh
fi

# asdf
# https://rgoswami.me/snippets/prog-lang-man/
if [ ! -d "$ASDF_DIR" ]; then
  # https://asdf-vm.com/guide/getting-started.html#_3-install-asdf

  # git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
  cd $OPT
  wget https://github.com/asdf-vm/asdf/archive/refs/tags/v0.10.0.zip 
  unzip v0.10.0.zip 
  mv asdf-0.10.0 asdf 

  . $OPT/asdf/asdf.sh

  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf plugin-add python
  asdf install python 3.9.0
  asdf global python 3.9.0
  asdf install nodejs 16.15.0
  asdf global nodejs 16.15.0

  # asdf plugin-add direnv
  # asdf install direnv latest
  # asdf global direnv latest

  # asdf plugin-add poetry https://github.com/asdf-community/asdf-poetry.git
fi

