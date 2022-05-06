# https://haydenjames.io/remove-snap-ubuntu-22-04-lts/
# https://gist.github.com/allisson/7ff8487b696fd30c4767341d3d797595
sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service

sudo snap remove --purge firefox
sudo snap remove --purge snap-store
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge gnome-3-38-2004
sudo snap remove --purge core20
sudo snap remove --purge bare
sudo snap remove --purge snapd
sudo apt remove -y --purge snapd
sudo apt-mark hold snapd # avoid install snapd again

sudo rm -rf /var/cache/snapd/

rm -rf ~/snap

sudo add-apt-repository -y ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

sudp apt update
sudo apt install firefox -y
