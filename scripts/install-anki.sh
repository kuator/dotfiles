#!/bin/bash

ANKI=$OPT/anki
PREFIX="/usr"
version=2.1.49
anki_version="anki-$version-linux"
anki_archive="$anki_version.tar.bz2"
cd $OPT

if [ ! -d $ANKI ]; then
  if [ ! -f $anki_archive ]; then
    wget https://github.com/ankitects/anki/releases/download/$version/$anki_archive
  fi
  tar xaf $anki_archive && mv $anki_version $ANKI
  echo 'anki downloaded'
fi

if [ -d $ANKI ]; then
  echo 'anki install folder exists'
  if [ ! -e "$PREFIX"/share/anki/ ]; then
    echo 'anki is not installed'
    cd $ANKI
    sudo PREFIX="/usr" ./install.sh
    mkdir -p ~/.local/share/Anki2/addons21/
    cp -r $DOTFILES/anki/addons21/*  ~/.local/share/Anki2/addons21
    git clone https://github.com/Ajatt-Tools/mpvacious ~/.config/mpv/scripts/mpvacious
    git clone https://github.com/Ajatt-Tools/PitchAccent.git --recurse-submodules -j8 ~/.local/share/Anki2/addons21/1225470483
    git clone https://github.com/Ajatt-Tools/Furigana.git --recurse-submodules -j8 ~/.local/share/Anki2/addons21/1344485230
    # need ssh
    # git clone https://github.com/Ajatt-Tools/PasteImagesAsWebP --recurse-submodules -j8 ~/.local/share/Anki2/addons21/1151815987
  fi
fi
