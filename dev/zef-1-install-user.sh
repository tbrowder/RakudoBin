#!/bin/bash

if [[ -z $1 ]]; then
    echo "Usage: $0 go"
    echo "  (as a normal user)"
    echo "  Installs zef for a normal user."
    exit
fi

# run as a normal user (not sudo, not root)
if [[ $EUID == 0 ]]; then
    echo "Please run as a normal user."
    exit
fi

#echo "DEBUG exit"
#exit

# run as a user
/opt/rakudo-pkg/bin/install-zef

echo "Installed zef for user $USER"
