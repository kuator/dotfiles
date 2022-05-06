git clone https://github.com/kuator/dotfiles.git $HOME/dotfiles
. ~/dotfiles/.profile

sudo apt update
sudo apt install git xcape xclip curl dirmngr gpg curl gawk
sudo apt-get install python3-dev python3-pip

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

# https://github.com/chrisbra/SudoEdit.vim/issues/48
sudo apt install ssh-askpass

# asdf
git clone https://github.com/asdf-vm/asdf.git $OPT/asdf

# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
. $OPT/asdf/asdf.sh

# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
sudo apt-get update;
sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add python
asdf install python 3.7.9
asdf global python 3.7.9
asdf install nodejs 16.15.0
asdf global python 16.15.0
asdf plugin-add direnv
asdf direnv setup --shell zsh --version latest

# git clone https://github.com/kuator/nvim $HOME/nvim

ln -sv ~/dotfiles/xkb $XDG_CONFIG_HOME/xkb
ln -sv ~/dotfiles/.xprofile $HOME/.xprofile
ln -sv ~/dotfiles/zsh $XDG_CONFIG_HOME/zsh
ln -sv ~/dotfiles/git $XDG_CONFIG_HOME/git
ln -sv ~/dotfiles/redshift.conf $XDG_CONFIG_HOME/redshift.conf
ln -sv ~/dotfiles/zathura/ $XDG_CONFIG_HOME/zathura
