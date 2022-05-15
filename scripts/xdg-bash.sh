#!/bin/bash


# https://hiphish.github.io/blog/2020/12/27/making-bash-xdg-compliant/

profile_bash_xdg=/etc/profile.d/bash_xdg.sh

if [ ! -f $profile_bash_xdg ]; then
  sudo mkdir -p $(dirname $profile_bash_xdg)
  echo '
# Make bash follow the XDG_CONFIG_HOME specification
_confdir=${XDG_CONFIG_HOME:-$HOME/.config}/bash
_datadir=${XDG_DATA_HOME:-$HOME/.local/share}/bash

# Source settings file
if [ -d "$_confdir" ]; then
    for f in bash_profile bashrc; do
        [ -f "$_confdir/$f" ] && . "$_confdir/$f"
    done
fi

# Change the location of the history file by setting the environment variable
[ ! -d "$_datadir" ] && mkdir -p "$_datadir"
HISTFILE="$_datadir/history"

unset _confdir
unset _datadir
  ' | sudo tee $profile_bash_xdg
fi


bashrc_bash_xdg=/etc/bash/bashrc.d/bash_xdg.sh

if [ ! -f $bashrc_bash_xdg ]; then
  sudo mkdir -p $(dirname $bashrc_bash_xdg)
  echo '
_confdir=${XDG_CONFIG_HOME:-$HOME/.config}/bash
_datadir=${XDG_DATA_HOME:-$HOME/.local/share}/bash

[[ -r "$_confdir/bashrc" ]] && . "$_confdir/bashrc"

[[ ! -d "$_datadir" ]] && mkdir -p "$_datadir"
HISTFILE=$_datadir/history

unset _confdir
unset _datadir
  ' | sudo tee $bashrc_bash_xdg
fi
