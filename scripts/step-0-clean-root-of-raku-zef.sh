#!/bin/bash

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo "  (as root, sudo ok)"
    echo "  Removes rakudo-pkg as well as root's .raku, .zef, and zef."
    exit
fi

# cleaning out rakudo-pkg, root's raku and zef
# run as root user
if [[ $EUID != 0 ]]; then
    echo "Please run as root"
    exit
fi

#echo "DEBUG exit"
#exit

apt-get remove rakudo-pkg
rm -rf /opt/rakudo-pkg
rm -rf /root/.raku /root/.zef /root/zef
rm -rf /etc/profile.d/rakudo-pkg.sh
apt-get update

# # clean repository info
# rm /etc/apt/sources.list.d/nxadm-pkgs-rakudo-pkg.list
# apt-get clean
# rm -rf /var/lib/apt/lists/*
# apt-get update

echo "Removal of rakudo-pkg is complete."
echo "Removal of root's .raku and .zef is complete."


