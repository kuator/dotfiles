#!/bin/bash

export DOTFILES="$HOME/dotfiles"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export SCRIPTS="$DOTFILES/scripts"
export OPT="$HOME/opt"
export ASDF_DIR="$OPT/asdf"

. $SCRIPTS/install-system-packages.sh

. $SCRIPTS/setup-fonts.sh

. $SCRIPTS/install-xdg-and-home-configs.sh

. $SCRIPTS/set-zsh-to-be-default-shell.sh

. $SCRIPTS/install-asdf.sh

OPT=$OPT . $SCRIPTS/install-anki.sh

dconf load /org/gnome/terminal/legacy/profiles:/ < $DOTFILES/gnome-terminal-profiles.dconf

. $SCRIPTS/disable-snap-ubuntu-22.04.sh
SCRIPTS=$SCRIPTS . $SCRIPTS/install-firefox.sh
. $SCRIPTS/change-xauthority-location.sh
. $SCRIPTS/disable-sudo-admin-successful.sh
. $SCRIPTS/xdg-bash.sh
# . $SCRIPTS/move-xsession-errors.sh

OPT=$OPT . $SCRIPTS/install-python-lsp.sh
