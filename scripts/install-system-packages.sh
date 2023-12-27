#!/bin/bash

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

# add_ppa neovim-ppa/unstable

# https://github.com/MrGlockenspiel/activate-linux

sudo apt update

declare -a packages=(
  zsh
  fzf zoxide
  git xcape xclip curl dirmngr gpg gawk 
  make build-essential libssl-dev zlib1g-dev 
  # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  libbz2-dev libreadline-dev libsqlite3-dev wget llvm 
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  zathura
  # https://github.com/chrisbra/SudoEdit.vim/issues/48
  ssh-askpass
  # for telescope
  ripgrep fd-find
  # neovim
  fonts-noto-cjk
  # anki paste images as webp
  webp
  #mpvacious
  mpv ffmpeg
  #anki 2.49
  libxcb-xinerama0 zstd
  #telegram
  telegram-desktop
  jq jsbeautifier
  redshift-gtk
  trash-cli
  unzip
  universal-ctags cscope
  skkdic skkdic-extra
  bbe
  vim-gtk
  # ruby
  # autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
)

apt_install_if_not_installed() {
  # https://stackoverflow.com/questions/1298066/how-can-i-check-if-a-package-is-installed-and-install-it-if-not#comment80142067_22592801
  if ! dpkg-query -W -f='${Status}' "$1"  | grep "ok installed"; then sudo apt install -y "$1"; fi
  echo ""$1" installed"
}

for package in "${packages[@]}"; do
  apt_install_if_not_installed "$package"
done
