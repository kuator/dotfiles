if strings /usr/sbin/lightdm | grep -q '.xsession-errors' ; then
  sudo apt install bbe
  bbe -e 's/.xsession-errors/.cache\x2Fxs-errors/' /usr/sbin/lightdm > outfile
  chmod +x outfile
  sudo mv /usr/sbin/lightdm /usr/sbin/lightdm-back
  sudo mv outfile /usr/sbin/lightdm
fi
