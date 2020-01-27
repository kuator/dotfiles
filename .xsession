if [ "$XDG_CURRENT_DESKTOP" = "i3" ]; then
    export QT_QPA_PLATFORMTHEME="qt5ct"
    export QT_PLUGIN_PATH=$HOME/.kde4/lib/kde4/plugins/:/usr/lib/kde4/plugins/
fi

xkbcomp $HOME/.config/xkb/my $DISPLAY 2> /dev/null
xcape -t 1000 -e "Hyper_R=space"
xset r rate 220 40

export XDG_CURRENT_DESKTOP=KDE 
export DESKTOP_SESSION=kde
