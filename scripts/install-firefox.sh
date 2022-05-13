if ! dpkg-query -W -f='${Status}' firefox  | grep "ok installed"; then
  sudo apt install -y firefox
  . $SCRIPTS/script.sh/patch-the-fox.sh
  mv ~/.mozilla/ $MOZILLA_XDG_HOME
else
  echo "firefox installed"
fi
