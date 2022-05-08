if [ ! -d $HOME/dotfiles ]; then
  git clone https://github.com/kuator/dotfiles.git $HOME/dotfiles
fi

export DOTFILES=$HOME/dotfiles
export OPT=$HOME/opt
export ASDF_DIR=$HOME/opt/asdf
mkdir -p $OPT

. $DOTFILES/.profile

dconf load /org/gnome/terminal/legacy/profiles:/ < $DOTFILES/gnome-terminal-profiles.dconf

apt_install_if_not_installed() {
  # https://stackoverflow.com/questions/1298066/how-can-i-check-if-a-package-is-installed-and-install-it-if-not#comment80142067_22592801
  if ! dpkg-query -W -f='${Status}' "$1"  | grep "ok installed"; then apt install "$1"; fi
  echo ""$1" installed"
}

# https://askubuntu.com/a/749379
add_ppa() {
  for i in "$@"; do
    if ! grep -q "^deb .*"$i"" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
      echo "Adding ppa:$i"
      sudo add-apt-repository -y ppa:$i
    else
      echo "ppa:$i already exists"
    fi
  done
}

add_ppa neovim-ppa/unstable

sudo apt update

declare -a packages=(
  zsh
  fzf zoxide
  git xcape xclip curl dirmngr gpg curl gawk 
  make build-essential libssl-dev zlib1g-dev 
  # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm 
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  zathura
  # https://github.com/chrisbra/SudoEdit.vim/issues/48
  ssh-askpass
  # for telescope
  ripgrep fd-find
  neovim
  fonts-noto-cjk
)

for package in "${packages[@]}"; do
  apt_install_if_not_installed "$package"
done

declare -a home_configs=(
  ".xprofile" ".profile"
)

declare -a xdg_configs=(
 "asdf" "zathura" "redshift.conf"
 "git" "asdf" "xkb" "zsh" ".ignore"
)

for config in "${home_configs[@]}"; do
  if [ -f $HOME/$config ]; then
    mv "$HOME/$config" "$HOME/${config}-old"
  fi

  if [ ! -e $HOME/$config ]; then
    ln -sv $DOTFILES/$config $HOME/$config
  fi
done

for config in "${xdg_configs[@]}"; do
  if [ ! -e $config ]; then
    ln -sv "$DOTFILES/$config" "$XDG_CONFIG_HOME/$config"
  fi
done

#zsh
# https://github.com/lkhphuc/dotfiles/blob/master/deploy.sh
check_default_shell() {
  if [ -z "${SHELL##*zsh*}" ] ;then
    echo "Default shell is zsh."
  else
    echo -n "Default shell is not zsh. Do you want to chsh -s \$(which zsh)? (y/n)"
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg && echo
    if echo "$answer" | grep -iq "^y" ;then
      chsh -s $(which zsh)
    else
      echo "Warning: Your configuration won't work properly. If you exec zsh, it'll exec tmux which will exec your default shell which isn't zsh."
    fi
  fi
}

check_default_shell

# asdf
if [ ! -d "$ASDF_DIR" ]; then
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
  # https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
  . $OPT/asdf/asdf.sh
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf plugin-add python
  asdf install python 3.7.9
  asdf global python 3.7.9
  asdf install nodejs 16.15.0
  asdf global python 16.15.0
  asdf plugin-add direnv
  asdf direnv setup --shell zsh --version latest
fi

if [ -d "$HOME/bin" ]; then
  mv $HOME/bin $HOME/bin-old
fi

if [ ! -e "$HOME/bin" ]; then
  ln -sv $DOTFILES/bin $HOME/bin
fi

