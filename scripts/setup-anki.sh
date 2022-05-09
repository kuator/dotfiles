sudo apt install libxcb-xinerama0
sudo apt install zstd
ANKI=$OPT/anki
cd $ANKI
wget https://github.com/ankitects/anki/releases/download/2.1.49/anki-2.1.49-linux.tar.bz2
tar xaf anki-2.1.49-linux.tar.bz2
cd anki-2.1.49-linux/
sudo ./install.sh
git clone 'https://github.com/Ajatt-Tools/PitchAccent.git' ~/.local/share/Anki2/addons21/pitch_accent
git clone 'https://github.com/Ajatt-Tools/Furigana.git' ~/.local/share/Anki2/addons21/ajt_furigana
cp -r $DOTFILES/anki/addons21/*  ~/.local/share/Anki2/addons21
