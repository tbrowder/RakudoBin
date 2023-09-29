#!/bin/bash

EXEDIR="/home/tbrowde/mydata/tbrowde-home/0-myservers/0-raku-zef-inst-scripts"

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo "  (as root, use sudo -s first)"
    echo "  Intalls rakudo-pkg."
    exit
fi

# installing rakudo-pkg
# run as root (not sudo) user
if [[ $EUID != 0 ]]; then 
    echo "Please run as root"
    exit
fi
if [[ -n $SUDO_USER ]]; then
    if [[ $PWD != $EXEDIR ]]; then
        echo "FATAL: Do not use 'sudo -i'"
        exit
    fi
fi

echo "Installing rakudo-pkg from a script in directory"
echo "  $EXEDIR"

#echo "DEBUG exit"
#exit

# running as the root user
apt-get install -y debian-keyring  # debian only
apt-get install -y debian-archive-keyring  # debian only
apt-get install -y apt-transport-https

# For Debian Stretch, Ubuntu 16.04 and later
keyring_location=/usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg

# For Debian Jessie, Ubuntu 15.10 and earlier
# keyring_location=/etc/apt/trusted.gpg.d/nxadm-pkgs-rakudo-pkg.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/gpg.0DD4CA7EB1C6CC6B.key' |  gpg --dearmor >> ${keyring_location}
curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.deb.txt?distro=debian&codename=buster' > /etc/apt/sources.list.d/nxadm-pkgs-rakudo-pkg.list
apt-get update
apt-get install rakudo-pkg
echo "Installation of raku is complete"

