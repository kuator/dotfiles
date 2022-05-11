ANKI=$OPT/anki
file=anki-2.1.49-linux.tar.bz2
mkdir -p ANKI
cd $ANKI
if [ ! -f $file ]; then
  wget https://github.com/ankitects/anki/releases/download/2.1.49/anki-2.1.49-linux.tar.bz2
  tar xaf anki-2.1.49-linux.tar.bz2
  cd anki-2.1.49-linux/
  sudo ./install.sh
  mkdir -p ~/.local/share/Anki2/addons21/
  git clone 'https://github.com/Ajatt-Tools/PitchAccent.git' ~/.local/share/Anki2/addons21/pitch_accent
  git clone 'https://github.com/Ajatt-Tools/Furigana.git' ~/.local/share/Anki2/addons21/ajt_furigana
  cp -r $DOTFILES/anki/addons21/*  ~/.local/share/Anki2/addons21
  git clone https://github.com/Ajatt-Tools/mpvacious ~/.config/mpv/scripts/mpvacious
fi
