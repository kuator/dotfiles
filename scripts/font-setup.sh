# cd /tmp && mkdir Noto && cd Noto
# sudo apt install subversion fontforge
# svn export 'https://github.com/ryanoasis/nerd-fonts/trunk/src/glyphs'
# mkdir src && mv glyphs src
# pip install --user configparser

# curl -L https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/font-patcher --output font-patcher

# wget 'https://fonts.google.com/download?family=Noto Sans JP' -O NotoSansJP.zip
# wget 'https://fonts.google.com/download?family=Noto Serif JP' -O NotoSerifJP.zip

# mkdir fonts
# unzip NotoSansJP.zip -d fonts
# unzip NotoSerifJP.zip -d fonts

# mkdir patched-fonts

# for filename in fonts/*.otf; do
#   fontforge -script font-patcher --powerline --no-progressbars "$filename" -out patched-fonts
# done

# cp patched-fonts/* $XDG_DATA_HOME/fonts
# fc-cache -fv
