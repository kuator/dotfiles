# https://ubuntuhandbook.org/index.php/2023/11/install-dotnet-8-ubuntu-22-04/

sudo wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg

echo '
Types: deb
URIs: https://packages.microsoft.com/ubuntu/22.04/prod/
Suites: jammy
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/microsoft.gpg
' | sudo tee /etc/apt/sources.list.d/microsoft.sources

sudo apt update

sudo apt install dotnet-sdk-8.0
