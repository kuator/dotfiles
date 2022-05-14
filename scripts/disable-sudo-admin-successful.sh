#!/bin/bash

disable_admin_file_in_home=/etc/sudoers.d/disable_admin_file_in_home
bashrc=/etc/bash.bashrc

if [ ! -f $disable_admin_file_in_home ]; then
  echo '
# Disable ~/.sudo_as_admin_successful file
Defaults !admin_flag
  ' | sudo tee $disable_admin_file_in_home

fi

if grep -q 'sudo_as_admin_successful' "$bashrc"; then
  sudo vi -E -s $bashrc << EOF
:%s/\v^\#.{-}sudo.{-}hint\_.{-}sudo_root\_.{-}^fi
:update
:quit
EOF

fi
