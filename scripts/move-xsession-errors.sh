#!/bin/bash

Xsession=/etc/X11/Xsession

if ! grep -q XDG_CACHE_HOME "$Xsession"; then
  cat > /tmp/HereFile <<HEREDOC
XDG_CACHE_HOME="\$HOME/.cache"
USERXSESSION="\$XDG_CACHE_HOME/X11/xsession"
USERXSESSIONRC="\$XDG_CACHE_HOME/X11/xsessionrc"
ALTUSERXSESSION="\$XDG_CACHE_HOME/X11/Xsession"
ERRFILE="\$XDG_CACHE_HOME/X11/xsession-errors"
HEREDOC

sed '/^ERRFILE=.*/ {
   r /tmp/HereFile
   d
   }' $Xsession

fi
