#!/usr/bin/env bash

# Exit on failure
set -e

wget https://github.com/scottkosty/install-tl-ubuntu/raw/master/install-tl-ubuntu && chmod +x ./install-tl-ubuntu
sudo apt-get update -qq
sudo apt-get install --fix-missing
sudo apt-get install --no-install-recommends -qq poppler-utils ghostscript imagemagick --fix-missing
sudo apt-get install --no-install-recommends -qq libfile-fcntllock-perl gcc equivs libwww-perl fontconfig unzip

pdfinfo -v
compare -version
gs -v

sudo ./install-tl-ubuntu --only-apt-and-dpkg
sudo wget http://mirror.utexas.edu/ctan/systems/texlive/tlnet/install-tl-unx.tar.gz -O install-tl-unx.tar.gz
tar -xf "install-tl-unx.tar.gz"
export tl_dir=$( ls | grep -P "install-tl-\d{8}$" | head -n 1 )


cd "${tl_dir}"
echo "i" | sudo -s ./install-tl -logfile install-tl.log -repository http://mirrors.rit.edu/CTAN/systems/texlive/tlnet -profile ../texlive.profile
export MAINTEXDIR=$(grep "TEXDIR:" "install-tl.log" | awk -F'"' '{ print $2 }')
sudo ln -s "${MAINTEXDIR}/bin"/* "/opt/texbin"
sudo sed -i 's/^PATH="/PATH="\/opt\/texbin:/' /etc/environment
cd ..

source /etc/environment &>/dev/null
source /etc/profile &>/dev/null
source ~/.profile &>/dev/null
unset _OLD_VIRTUAL_PATH
source ~/virtualenv/python2.7/bin/activate &>/dev/null

export PATH

sudo -i tlmgr update --self --all
