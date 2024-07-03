#!/bin/bash

OPT=$HOME/opt

ANKI=$OPT/anki
PREFIX="/usr"

# version=23.12.1
version=24.06.2
anki_version="anki-$version-linux-qt6"
anki_archive_zst="$anki_version.tar.zst "
anki_archive_tar="$anki_version.tar"
mkdir -p $OPT && cd $OPT



if [ ! -d $ANKI ]; then
  if [ ! -f $anki_archive_zst ]; then
    echo https://github.com/ankitects/anki/releases/download/$version/$anki_archive_zst
    wget https://github.com/ankitects/anki/releases/download/$version/$anki_archive_zst
  fi
  unzstd $anki_archive_zst
  tar -xvf $anki_archive_tar && mv $anki_version $ANKI
  echo 'anki downloaded'
fi

if [ -d $ANKI ]; then
  echo 'anki install folder exists'
  if [ ! -e "$PREFIX"/share/anki/ ]; then
    echo 'anki is not installed'
    cd $ANKI
    sudo PREFIX="/usr" ./install.sh
    if [ ! -d $XDG_CONFIG_HOME/mpv ]; then
      ln -sv $DOTFILES/mpv $XDG_CONFIG_HOME/mpv
    fi
    if [ ! -d $XDG_CONFIG_HOME/mpv/scripts/mpvacious ]; then
      git clone https://github.com/Ajatt-Tools/mpvacious $XDG_CONFIG_HOME/mpv/scripts/mpvacious
    fi

    if [ ! -d $XDG_DATA_HOME/Anki2/addons21 ]; then
      mkdir -p $XDG_DATA_HOME/Anki2/addons21/
      cp -r $DOTFILES/anki/addons21/*  $XDG_DATA_HOME/Anki2/addons21
      git clone https://github.com/Ajatt-Tools/PitchAccent.git --recurse-submodules -j8 $XDG_DATA_HOME/Anki2/addons21/1225470483
      git clone https://github.com/Ajatt-Tools/Japanese.git --recurse-submodules -j8 $XDG_DATA_HOME/Anki2/addons21/1344485230
    fi
  fi
fi

LOCAL_YOMICHAN_AUDIO_FILE="$HOME/Downloads/local-yomichan-audio-collection-2023-06-11-opus.tar.xz"

if [ -f "$LOCAL_YOMICHAN_AUDIO_FILE" ]; then
    echo "$LOCAL_YOMICHAN_AUDIO_FILE exists."
else 
    echo "$LOCAL_YOMICHAN_AUDIO_FILE does not exist."
    exit 1
fi
