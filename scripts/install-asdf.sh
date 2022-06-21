#!/bin/bash

export ASDF_DIR="$OPT/asdf"

# asdf
# https://rgoswami.me/snippets/prog-lang-man/
if [ ! -d "$ASDF_DIR" ]; then
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
  # https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
  . $OPT/asdf/asdf.sh
  ## Install golang plugin
  asdf plugin-add golang
  # Install global version golang
  asdf install golang 1.17.7
  # Setup global golang version
  asdf global golang 1.17.7

  ## Install rust plugin
  asdf plugin-add rust https://github.com/asdf-community/asdf-rust.git
  # Install global version rust
  asdf install rust 1.60.0
  # Setup global rust version
  asdf global rust 1.60.0

  ## Install rust plugin
  asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
  asdf install deno 1.22.0
  asdf global deno 1.22.0

  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf plugin-add python
  asdf install python 3.7.9
  asdf global python 3.7.9
  asdf install nodejs 16.15.0
  asdf global nodejs 16.15.0
  asdf plugin-add direnv
  asdf install direnv latest
  asdf global direnv latest

  asdf plugin add coursier

  # asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
fi
