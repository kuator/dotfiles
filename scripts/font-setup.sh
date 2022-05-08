cd /tmp
wget 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip'
unzip UbuntuMono.zip -d $XDG_DATA_HOME/fonts
fc-cache -fv
