#!/bin/bash

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo "  (as root, sudo ok)"
    echo "  Installs zef for root."
    exit
fi

# run as root
if [[ $EUID != 0 ]]; then
    echo "Please run as root"
    exit
fi

#echo "DEBUG exit"
#exit

/opt/rakudo-pkg/bin/install-zef

echo "Installed zef for root"

