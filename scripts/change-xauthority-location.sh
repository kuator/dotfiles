#!/bin/bash


echo '
[LightDM]
user-authority-in-system-dir=true
' | sudo tee -a /etc/lightdm/lightdm.conf
