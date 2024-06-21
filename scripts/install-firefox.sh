#!/bin/bash

if ! dpkg-query -W -f='${Status}' firefox  | grep "ok installed"; then

  sudo add-apt-repository -y ppa:mozillateam/ppa
  echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
  ' | sudo tee /etc/apt/preferences.d/mozilla-firefox

  sudo apt update
  sudo apt install -y firefox
else
  echo "firefox installed"
fi
