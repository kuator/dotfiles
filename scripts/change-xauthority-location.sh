#!/bin/bash

if [ ! -f /etc/lightdm/lightdm.conf ]; then
  echo '
  [LightDM]
  user-authority-in-system-dir=true
  ' | sudo tee -a /etc/lightdm/lightdm.conf
elif ! grep -q 'user-authority-in-system-dir=true' "/etc/lightdm/lightdm.conf"; then
  echo '
  [LightDM]
  user-authority-in-system-dir=true
  ' | sudo tee -a /etc/lightdm/lightdm.conf
fi
