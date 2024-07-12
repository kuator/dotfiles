#!/bin/bash

export DOTFILES="$HOME/dotfiles"
export XDG_CONFIG_HOME="$HOME/.config"

mkdir -p $XDG_CONFIG_HOME/Code/User
ln -sv $DOTFILES/codium/keybindings.json $XDG_CONFIG_HOME/Code/User/keybindings.json
ln -sv $DOTFILES/codium/settings.json $XDG_CONFIG_HOME/Code/User/settings.json

code_destkop_file=$XDG_DATA_HOME/applications/code.desktop

cat  <<EOF > $code_destkop_file
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=code %F
Icon=vscode
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Name[de]=Neues leeres Fenster
Name[es]=Nueva ventana vacía
Name[fr]=Nouvelle fenêtre vide
Name[it]=Nuova finestra vuota
Name[ja]=新しい空のウィンドウ
Name[ko]=새 빈 창
Name[ru]=Новое пустое окно
Name[zh_CN]=新建空窗口
Name[zh_TW]=開新空視窗
Exec=code --new-window %F
Icon=vscode
EOF
