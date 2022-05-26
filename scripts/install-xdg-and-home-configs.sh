#!/bin/bash

symlink_config(){
  source="$1"
  destination="$2"
  if [ -L "$destination" ] ; then
    if [ -e "$destination" ]; then
      echo "symbolic link $destination exists"
    else
      echo "$destination Broken link :("
    fi
  elif [ -e "$destination" ] ; then
     mv "$destination" "$HOME/${config}-old"
     ln -sv "$source" "$destination"
  else
    echo "Missing, linking..."
    ln -sv "$source" "$destination"
  fi
}

export DOTFILES=$HOME/dotfiles
export XDG_CONFIG_HOME=$HOME/.config
export OPT=$HOME/opt

mkdir -p $OPT

if [ ! -d $DOTFILES ]; then
  git clone https://github.com/kuator/dotfiles.git $DOTFILES
fi

if [ ! -d $XDG_CONFIG_HOME/nvim ]; then
  git clone https://github.com/kuator/nvim.git $XDG_CONFIG_HOME/nvim
fi

. $DOTFILES/.profile

declare -a home_configs=(
  ".xprofile" ".profile" "bin"
)

declare -a xdg_configs=(
 "asdf" "zathura" "bash"
 "git" "xkb" "zsh" ".ignore"
 "direnv" "ssh"
)

for config in "${home_configs[@]}"; do
  symlink_config "$DOTFILES/$config" "$HOME/$config"
done

for config in "${xdg_configs[@]}"; do
  symlink_config "$DOTFILES/$config" "$XDG_CONFIG_HOME/$config"
done

if [ ! -f $WGETRC ]; then
  cp /etc/wgetrc $WGETRC
fi

REDSHIFTRC=$XDG_CONFIG_HOME/redshift.conf
if [ ! -f $REDSHIFTRC ]; then
  cp ~/dotfiles/redshift.conf ~/.config
fi
